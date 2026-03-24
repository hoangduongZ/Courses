# TASK 05 - Transactions và Isolation

> Mục tiêu: trả lời chắc các câu hỏi về consistency, rollback, isolation và áp dụng đúng trong Spring Boot/JPA để tránh bug dữ liệu production.

---

## 1. Mental Model: Transaction giải quyết vấn đề gì?

Transaction là đơn vị công việc đảm bảo dữ liệu đi từ trạng thái hợp lệ A sang trạng thái hợp lệ B.

Trong JPA/Spring:
1. Service method có `@Transactional` mở transaction
2. Entity thay đổi trong persistence context
3. Hibernate flush SQL
4. DB commit hoặc rollback toàn bộ

Nếu thiếu transaction boundary rõ ràng, bạn dễ gặp:
- Dữ liệu nửa chừng (partial update)
- Race condition
- Hành vi khó đoán khi lỗi phát sinh giữa chừng

---

## 2. ACID trong ngữ cảnh ứng dụng Java

- Atomicity: hoặc thành công tất cả, hoặc fail tất cả
- Consistency: luôn thỏa constraint/business rule sau commit
- Isolation: transaction đồng thời không phá dữ liệu nhau
- Durability: commit xong thì dữ liệu bền vững

Điểm cần nhớ khi phỏng vấn:
- ACID là mục tiêu cấp DB + transaction manager
- Ứng dụng phải thiết kế đúng boundary thì ACID mới phát huy

---

## 3. Propagation trong Spring (`@Transactional`)

## 3.1 `REQUIRED` (mặc định)
- Có transaction sẵn thì dùng chung
- Không có thì mở mới

Khi dùng:
- Phù hợp đa số business flow

## 3.2 `REQUIRES_NEW`
- Luôn tạo transaction mới, tạm treo transaction hiện tại

Khi dùng:
- Audit/log độc lập
- Tác vụ cần commit dù transaction ngoài fail

Rủi ro:
- Dễ phá tính “all-or-nothing” của luồng chính nếu lạm dụng

## 3.3 `MANDATORY`
- Bắt buộc phải có transaction đang chạy, nếu không sẽ ném exception

Khi dùng:
- API nội bộ chỉ được gọi trong transaction hiện hữu

## 3.4 Các propagation khác (ít dùng hơn)
- `SUPPORTS`, `NOT_SUPPORTED`, `NEVER`, `NESTED`
- Chỉ dùng khi bạn thật sự hiểu semantics và tác động nghiệp vụ

---

## 4. Isolation level: chọn đúng để cân bằng an toàn và hiệu năng

## 4.1 Các hiện tượng cần nắm
- Dirty read: đọc dữ liệu chưa commit từ transaction khác
- Non-repeatable read: cùng 1 query, đọc 2 lần ra kết quả khác
- Phantom read: cùng điều kiện, lần sau xuất hiện thêm/mất bớt dòng

## 4.2 Mức isolation phổ biến

### `READ_COMMITTED`
- Chặn dirty read
- Vẫn có thể gặp non-repeatable read, phantom
- Thường là mặc định tốt cho phần lớn hệ thống OLTP

### `REPEATABLE_READ`
- Chặn dirty read và non-repeatable read
- Tùy DB mà phantom có thể còn
- Phù hợp các luồng cần đọc ổn định trong transaction

### `SERIALIZABLE`
- Mức mạnh nhất, gần như chạy tuần tự logic
- An toàn cao nhưng giảm throughput rõ rệt
- Chỉ dùng cho đoạn nghiệp vụ cực nhạy dữ liệu

Quy tắc thực tế:
- Bắt đầu với `READ_COMMITTED`
- Nâng isolation cho đúng điểm nóng thay vì nâng toàn hệ thống

---

## 5. Rollback rules: checked vs runtime exception

Mặc định Spring:
- Rollback với `RuntimeException` và `Error`
- Không rollback với checked exception (trừ khi cấu hình)

Ví dụ:
```java
@Transactional(rollbackFor = Exception.class)
public void placeOrder(...) throws Exception {
    // checked exception cũng rollback
}
```

Pitfall hay gặp:
- Ném checked exception nhưng tưởng đã rollback

Khuyến nghị:
- Chuẩn hóa exception chiến lược theo domain
- Khai báo `rollbackFor` rõ khi cần

---

## 6. Savepoint và `NESTED`: khi nào cần?

`NESTED` cho phép rollback một phần qua savepoint (phụ thuộc transaction manager/DB).

Dùng khi:
- Muốn rollback một đoạn nhỏ nhưng vẫn giữ transaction ngoài tiếp tục

Lưu ý:
- Không phải môi trường nào cũng hỗ trợ đầy đủ
- `REQUIRES_NEW` thường dễ hiểu hơn trong nhiều case

---

## 7. Transactional write-behind và thứ tự flush

Hibernate không update DB ngay khi gọi setter.
SQL được sinh khi flush (thường trước commit hoặc trước một số query).

Hệ quả quan trọng:
- Lỗi constraint có thể xuất hiện muộn ở cuối method
- Thứ tự SQL bị ảnh hưởng bởi quan hệ entity, FK, cascade, batching

Kỹ thuật dùng trong debug:
- Gọi `entityManager.flush()` tại điểm nghi ngờ để fail-fast

---

## 8. `@Transactional(readOnly = true)` có tác dụng gì?

Lợi ích:
- Tối ưu đường đọc ở một số DB/driver
- Giảm chi phí dirty checking ở một số trường hợp Hibernate/Spring setup
- Truyền thông điệp rõ: method chỉ đọc

Hiểu đúng:
- `readOnly = true` không phải cơ chế bảo mật tuyệt đối chống ghi
- Vẫn có thể ghi nếu code/DB cho phép, tùy cấu hình

Khuyến nghị:
- Dùng readOnly cho query use case
- Tách method đọc/ghi rõ ràng

---

## 9. `@Transactional` trên interface: trap thường gặp

Trong Spring, transaction thường chạy qua proxy.

Rủi ro:
- Self-invocation (method trong cùng class gọi nhau) có thể bypass proxy
- Đặt annotation ở interface nhưng cấu hình/proxy mode không phù hợp có thể gây hiểu nhầm

Best practice:
- Đặt `@Transactional` ở service class/method cụ thể
- Tránh self-invocation cho method cần transaction khác nhau

---

## 10. Mẫu service chuẩn cho ghi dữ liệu

```java
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final AuditService auditService;

    @Transactional
    public void placeOrder(PlaceOrderCommand cmd) {
        Order order = Order.create(cmd);
        orderRepository.save(order);

        // Nếu cần audit độc lập, cân nhắc REQUIRES_NEW trong AuditService
        auditService.logOrderPlaced(order.getId());
    }
}
```

---

## 11. Lỗi phổ biến và cách tránh

1. Dùng `REQUIRES_NEW` tràn lan
- Hậu quả: mất tính nguyên khối của luồng nghiệp vụ
- Cách tránh: chỉ dùng cho tác vụ thật sự độc lập (audit, outbox...)

2. Hiểu sai rollback mặc định
- Hậu quả: exception checked nhưng dữ liệu vẫn commit
- Cách tránh: cấu hình `rollbackFor` rõ ràng

3. Chọn isolation quá cao toàn hệ thống
- Hậu quả: lock nhiều, giảm throughput
- Cách tránh: nâng isolation theo từng use case nóng

4. Đặt transaction ở controller
- Hậu quả: boundary lỏng, khó bảo trì
- Cách tránh: transaction ở service layer

5. Tin rằng `readOnly = true` chặn tuyệt đối ghi
- Hậu quả: sai kỳ vọng bảo vệ dữ liệu
- Cách tránh: dùng thêm ràng buộc nghiệp vụ + DB permission

---

## 12. Checklist trước khi merge code

- Đã xác định boundary transaction tại service chưa?
- Propagation đã đúng với nghiệp vụ chưa (`REQUIRED`/`REQUIRES_NEW`)?
- Rollback rule có đúng với loại exception đang ném không?
- Isolation đã cân bằng an toàn và hiệu năng chưa?
- Method đọc đã dùng `readOnly = true` khi phù hợp chưa?
- Có test cho case rollback và concurrent access quan trọng chưa?

---

## 13. Trả lời nhanh khi phỏng vấn

Câu hỏi: Khi nào dùng `REQUIRES_NEW`?
- Trả lời gọn: khi cần transaction độc lập, ví dụ ghi audit/outbox dù transaction chính fail.

Câu hỏi: Vì sao gặp tình trạng checked exception mà vẫn commit?
- Trả lời gọn: vì mặc định Spring chỉ rollback runtime exception; cần `rollbackFor` nếu muốn rollback checked exception.

Câu hỏi: Chọn isolation level thế nào?
- Trả lời gọn: mặc định bắt đầu từ `READ_COMMITTED`, chỉ nâng mức cho đoạn nghiệp vụ nhạy xung đột dữ liệu.

---

## Tổng kết

Task 05 cần nắm chắc 5 điểm:
1. Transaction boundary đúng ở service
2. Chọn propagation theo nghiệp vụ, không theo cảm tính
3. Hiểu isolation qua hiện tượng dirty/non-repeatable/phantom
4. Nắm rollback rule để không commit nhầm
5. Tận dụng readOnly và flush đúng chỗ để tối ưu + debug

Nắm chắc 5 điểm này, bạn sẽ trả lời tốt phần transaction trong phỏng vấn và giảm mạnh lỗi dữ liệu runtime.