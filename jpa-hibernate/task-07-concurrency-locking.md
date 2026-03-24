# TASK 07 - Concurrency và Locking

> Mục tiêu: xử lý đúng race condition, lost update và trả lời chắc phần locking trong phỏng vấn JPA/Hibernate.

---

## 1. Mental Model: vì sao cần locking?

Trong hệ thống nhiều người dùng, nhiều transaction có thể sửa cùng một bản ghi tại cùng thời điểm.

Nếu không kiểm soát đồng thời (concurrency control), bạn sẽ gặp:
- Lost update: ghi đè dữ liệu của nhau
- Dirty write/read theo các tình huống biên
- Dữ liệu cuối cùng sai logic nghiệp vụ

Locking là cơ chế giúp:
1. Phát hiện xung đột
2. Hoặc ngăn xung đột xảy ra
3. Đảm bảo consistency khi nhiều transaction chạy song song

---

## 2. Race condition và lost update trong thực tế

Ví dụ kinh điển:
1. T1 đọc `stock = 10`
2. T2 đọc `stock = 10`
3. T1 trừ 3, ghi `stock = 7`
4. T2 trừ 4, ghi `stock = 6`

Kết quả đúng mong muốn phải là `3`, nhưng hệ thống ghi thành `6`.
Đây là lost update do cập nhật dựa trên dữ liệu cũ.

---

## 3. Optimistic Locking với `@Version`

## 3.1 Cơ chế
Optimistic locking giả định xung đột hiếm, nên:
- Không khóa cứng khi đọc
- Kiểm tra version lúc update

Khi update, Hibernate sinh SQL kiểu:
```sql
update product
set stock = ?, version = version + 1
where id = ? and version = ?
```

Nếu `where` không match (version đã đổi), update ảnh hưởng 0 dòng -> ném exception xung đột.

## 3.2 Cách dùng
Thêm field version vào entity:
```java
@Version
private Long version;
```

Có thể dùng kiểu:
- `Long`/`Integer` (phổ biến)
- `Timestamp` (ít dùng hơn, phụ thuộc ngữ cảnh)

## 3.3 Ưu điểm
- Throughput tốt khi xung đột thấp
- Không giữ lock DB lâu
- Phù hợp hệ thống đọc nhiều, ghi vừa phải

## 3.4 Nhược điểm
- Cần xử lý retry/conflict ở tầng service/API
- Nếu tỉ lệ xung đột cao, người dùng sẽ gặp lỗi thường xuyên

---

## 4. Xử lý optimistic conflict đúng cách

Khi gặp `OptimisticLockException` hoặc `ObjectOptimisticLockingFailureException` (Spring), bạn có 3 chiến lược:

1. Retry tự động có giới hạn
- Dùng cho thao tác idempotent
- Kèm backoff để giảm tranh chấp

2. Báo conflict cho client
- Trả mã phù hợp (thường `409 Conflict`)
- Cho người dùng biết dữ liệu đã thay đổi, cần tải lại

3. Merge nghiệp vụ
- Dùng khi có thể gộp thay đổi theo domain rule

Khuyến nghị:
- Không nuốt exception rồi ghi đè mù quáng.

---

## 5. Pessimistic Locking (`PESSIMISTIC_READ`/`PESSIMISTIC_WRITE`)

## 5.1 Cơ chế
Pessimistic locking khóa record ở DB ngay khi đọc (thường qua `SELECT ... FOR UPDATE`).

Mục tiêu:
- Ngăn transaction khác ghi vào dữ liệu đang xử lý

## 5.2 Các lock mode chính
- `PESSIMISTIC_READ`: ưu tiên đọc ổn định, chặn ghi tùy DB
- `PESSIMISTIC_WRITE`: khóa mạnh, transaction khác khó đọc/ghi tùy cơ chế DB

## 5.3 Khi nên dùng
- Tỉ lệ xung đột cao
- Nghiệp vụ tài chính/đặt hàng cần serialize đoạn cập nhật quan trọng
- Không chấp nhận retry thất bại nhiều lần

## 5.4 Rủi ro
- Chờ lock lâu -> timeout
- Deadlock nếu lock nhiều tài nguyên khác thứ tự
- Giảm throughput khi tải cao

---

## 6. Lock timeout và deadlock: cần chuẩn bị trước

## 6.1 Lock timeout
Có thể cấu hình lock timeout để tránh treo lâu.

Ví dụ hint JPA:
```java
query.setHint("jakarta.persistence.lock.timeout", 3000);
```

(Đơn vị và mức hỗ trợ phụ thuộc provider/DB.)

## 6.2 Deadlock
Deadlock thường đến từ:
- Transaction A lock bản ghi X rồi chờ Y
- Transaction B lock bản ghi Y rồi chờ X

Cách giảm deadlock:
1. Lock theo thứ tự nhất quán
2. Giữ transaction ngắn
3. Tránh giữ lock khi gọi dịch vụ ngoài
4. Có cơ chế retry khi DB trả lỗi deadlock

---

## 7. `OPTIMISTIC_FORCE_INCREMENT`: khi nào dùng?

`OPTIMISTIC_FORCE_INCREMENT` buộc tăng version ngay cả khi entity chưa đổi dữ liệu đáng kể.

Dùng khi:
- Bạn muốn đánh dấu “tài nguyên đã được chạm” để transaction khác phát hiện xung đột
- Ví dụ một aggregate có nhiều nhánh cập nhật cần đồng bộ logic cạnh tranh

Lưu ý:
- Chỉ dùng khi bạn thực sự hiểu ảnh hưởng tới tần suất conflict

---

## 8. Kịch bản chọn chiến lược lock (thực chiến)

## 8.1 Đơn hàng thương mại điện tử
- Trường hợp bình thường: optimistic lock cho `Order`/`Inventory`
- Điểm nóng tồn kho flash sale: cân nhắc pessimistic hoặc cơ chế reserve riêng

## 8.2 Hồ sơ người dùng cập nhật hiếm
- Optimistic lock là đủ

## 8.3 Bảng kế toán/quỹ tiền
- Có thể cần pessimistic ở đoạn critical write
- Kèm transaction ngắn và quy tắc lock nhất quán

---

## 9. Mẫu code tham khảo

## 9.1 Entity với `@Version`
```java
@Entity
public class Product {

    @Id
    private Long id;

    private int stock;

    @Version
    private Long version;
}
```

## 9.2 Pessimistic lock trong repository
```java
public interface ProductRepository extends JpaRepository<Product, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from Product p where p.id = :id")
    Optional<Product> findForUpdate(@Param("id") Long id);
}
```

## 9.3 Service xử lý conflict
```java
@Transactional
public void decreaseStock(Long productId, int qty) {
    Product p = productRepository.findById(productId)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));

    if (p.getStock() < qty) {
        throw new IllegalStateException("Insufficient stock");
    }

    p.setStock(p.getStock() - qty);
    // Optimistic locking sẽ kiểm tra version lúc flush/commit.
}
```

---

## 10. Lỗi phổ biến và cách tránh

1. Không có `@Version` nhưng nghĩ rằng đã chống lost update
- Hậu quả: ghi đè dữ liệu âm thầm
- Cách tránh: thêm `@Version` cho entity có cập nhật cạnh tranh

2. Dùng pessimistic lock tràn lan
- Hậu quả: nghẽn lock, giảm throughput
- Cách tránh: chỉ khóa ở đoạn critical ngắn

3. Không xử lý exception lock conflict
- Hậu quả: trải nghiệm người dùng kém, lỗi 500 không rõ nguyên nhân
- Cách tránh: chuẩn hóa xử lý `OptimisticLockException`, lock timeout, deadlock

4. Transaction quá dài
- Hậu quả: giữ lock lâu, tăng khả năng deadlock
- Cách tránh: rút ngắn transaction, bỏ I/O ngoài DB ra ngoài transaction nếu có thể

5. Lock không theo thứ tự nhất quán
- Hậu quả: deadlock ngẫu nhiên
- Cách tránh: quy ước thứ tự lock theo id/tài nguyên

---

## 11. Checklist trước khi merge code

- Entity cập nhật đồng thời đã có `@Version` chưa?
- Đã chọn chiến lược lock theo mức xung đột thực tế chưa?
- Có xử lý `OptimisticLockException`/timeout/deadlock chưa?
- Transaction đã đủ ngắn chưa?
- Có benchmark hoặc test concurrent cho luồng quan trọng chưa?
- Với pessimistic lock, đã có timeout và thứ tự lock nhất quán chưa?

---

## 12. Trả lời nhanh khi phỏng vấn

Câu hỏi: Optimistic và pessimistic khác nhau thế nào?
- Trả lời gọn: optimistic không khóa khi đọc, kiểm tra version lúc ghi; pessimistic khóa ở DB từ sớm để ngăn transaction khác can thiệp.

Câu hỏi: Khi nào chọn optimistic lock?
- Trả lời gọn: khi xung đột thấp, cần throughput cao và chấp nhận xử lý conflict bằng retry/409.

Câu hỏi: Vì sao vẫn deadlock dù đã lock?
- Trả lời gọn: vì lock nhiều tài nguyên theo thứ tự khác nhau giữa các transaction; cần thống nhất thứ tự lock và rút ngắn transaction.

---

## Tổng kết

Task 07 cần nắm chắc 5 điểm:
1. Nhận diện race condition và lost update
2. Dùng `@Version` để bật optimistic locking
3. Chọn pessimistic lock cho điểm nóng xung đột cao
4. Xử lý timeout/deadlock/conflict có chiến lược
5. Thiết kế transaction ngắn, lock có kỷ luật

Nắm chắc 5 điểm này giúp bạn bảo vệ dữ liệu nhất quán khi hệ thống chạy đồng thời cao và trả lời tốt phần locking trong phỏng vấn.