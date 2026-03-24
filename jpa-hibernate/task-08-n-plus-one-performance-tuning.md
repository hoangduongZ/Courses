# TASK 08 - N+1 và Performance Tuning

> Mục tiêu: phát hiện và xử lý N+1 có hệ thống, giảm query thừa, tối ưu batch và giữ hiệu năng ổn định khi dữ liệu tăng.

---

## 1. Mental Model: hiệu năng JPA thường vỡ ở đâu?

JPA chậm không phải vì ORM "tự nó chậm", mà thường do:
1. Query phát sinh ngoài kiểm soát (N+1)
2. Tải dư dữ liệu (over-fetch)
3. Pagination + fetch sai chiến lược
4. Thiếu đo lường query count/thời gian thực

Mục tiêu tuning:
- Đúng dữ liệu cho đúng use case
- Ít query nhất có thể nhưng vẫn đúng nghiệp vụ
- Query có thể dự đoán và theo dõi được

---

## 2. N+1 là gì và vì sao nguy hiểm?

Mẫu lỗi điển hình:
- Query 1: lấy danh sách parent
- Query 2..N: mỗi parent lại query association

Ví dụ:
- Lấy 200 `Order`
- Mỗi `Order` truy cập `customer` -> thêm 200 query

Hệ quả:
- Latency tăng tuyến tính
- DB connection bị chiếm lâu
- Throughput giảm mạnh khi traffic tăng

---

## 3. Detect N+1: đừng tối ưu theo cảm giác

## 3.1 Bật SQL log và bind params

Cấu hình thường dùng:
```properties
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.show-sql=true
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.orm.jdbc.bind=TRACE
```

## 3.2 Dùng công cụ quan sát query
- p6spy / datasource-proxy để đếm query theo request
- APM (nếu có) để thấy endpoint nào sinh quá nhiều SQL

## 3.3 Đặt ngưỡng kiểm soát
- Viết integration test assert số query cho use case quan trọng
- Theo dõi p95/p99 response time trước và sau tuning

---

## 4. Chiến lược xử lý N+1: chọn đúng công cụ

## 4.1 Fetch Join

Ưu điểm:
- Giảm số query ngay lập tức cho association cần thiết

Ví dụ:
```jpql
select o from Order o
join fetch o.customer
where o.status = :status
```

Cảnh báo:
- Dùng với collection + pageable dễ gây duplicate/sai phân trang

## 4.2 `@EntityGraph`

Ưu điểm:
- Tách fetch plan khỏi logic query
- Dễ maintain hơn khi nhiều use case đọc

Ví dụ:
```java
@EntityGraph(attributePaths = {"customer"})
List<Order> findByStatus(OrderStatus status);
```

## 4.3 Batch Fetch

Cấu hình:
```properties
spring.jpa.properties.hibernate.default_batch_fetch_size=50
```

Tác dụng:
- Khi truy cập lazy nhiều record cùng loại, Hibernate gom thành truy vấn theo lô

Khi phù hợp:
- Màn hình list truy cập lặp association
- Muốn giữ lazy mà vẫn giảm query

---

## 5. Pagination + Fetch Join: pitfall rất phổ biến

Vấn đề:
- Fetch join collection làm nhân bản dòng parent
- `Pageable` chạy sai kỳ vọng
- `DISTINCT` có thể xử lý ở memory, vẫn tốn tài nguyên

Giải pháp ổn định (2 bước):
1. Query page ID của parent
2. Query chi tiết theo tập ID (fetch association cần thiết)
3. Map DTO trả về

Mẫu tư duy:
- Bước 1 tối ưu cho phân trang
- Bước 2 tối ưu cho dữ liệu hiển thị

---

## 6. DTO Projection vs Entity Load

## 6.1 DTO Projection
Dùng cho API đọc/list/report.

Ưu điểm:
- Chỉ lấy cột cần thiết
- Giảm memory và serialization cost
- Hạn chế lazy load bất ngờ

## 6.2 Entity Load
Dùng khi cần lifecycle/dirty checking và thao tác nghiệp vụ sâu.

Khuyến nghị:
- Read path: ưu tiên DTO/projection
- Write path: entity managed

---

## 7. `@QueryHints` và batch optimization

Bạn có thể gắn hint cho query/repository để điều chỉnh cách Hibernate tương tác DB.

Ví dụ thường gặp:
- Fetch size
- Read-only hint
- Timeout hint

Lưu ý:
- Hiệu quả phụ thuộc driver/DB/provider
- Luôn benchmark trước khi áp dụng rộng

---

## 8. Quy trình tuning thực chiến (nên làm theo thứ tự)

1. Xác định endpoint chậm bằng số liệu thật
2. Ghi lại query count và thời gian baseline
3. Chọn giải pháp nhỏ nhất đủ hiệu quả (`EntityGraph`, fetch join, batch fetch, DTO)
4. Đo lại sau thay đổi
5. Giữ lại thay đổi nào cải thiện rõ ràng, rollback thay đổi nhiễu

Nguyên tắc:
- Không tối ưu mù
- Không "đập" EAGER toàn bộ để chữa N+1

---

## 9. Mẫu repository tham khảo

```java
public interface OrderRepository extends JpaRepository<Order, Long> {

    @EntityGraph(attributePaths = {"customer"})
    @Query("select o from Order o where o.status = :status")
    List<Order> findWithCustomerByStatus(@Param("status") OrderStatus status);

    @Query("select o.id from Order o where o.status = :status")
    Page<Long> findPageIdsByStatus(@Param("status") OrderStatus status, Pageable pageable);

    @Query("select o from Order o join fetch o.customer where o.id in :ids")
    List<Order> findDetailByIds(@Param("ids") List<Long> ids);
}
```

---

## 10. Lỗi phổ biến và cách tránh

1. Bật SQL log nhưng không đọc theo request
- Hậu quả: khó xác định chỗ phát sinh N+1
- Cách tránh: trace theo endpoint cụ thể

2. Dùng fetch join sâu cho mọi màn hình
- Hậu quả: query phình to, duplicate row
- Cách tránh: tối ưu theo use case, không theo thói quen

3. Dùng entity cho tất cả API read
- Hậu quả: tải dư dữ liệu, dễ lazy load ngoài ý muốn
- Cách tránh: projection/DTO cho read path

4. Không tách pagination và fetch detail
- Hậu quả: page sai, hiệu năng kém khi data lớn
- Cách tránh: áp dụng chiến lược 2 bước

5. Không benchmark trước/sau
- Hậu quả: “tối ưu” nhưng không biết có cải thiện thật không
- Cách tránh: đo query count + latency có kiểm chứng

---

## 11. Checklist trước khi merge code

- Endpoint chính đã có số liệu baseline (query count/latency) chưa?
- N+1 đã được chứng minh và xử lý đúng kỹ thuật chưa?
- Read path đã ưu tiên DTO/projection chưa?
- Pagination có tách bước lấy ID và bước lấy detail khi cần chưa?
- `default_batch_fetch_size` đã cấu hình và kiểm chứng chưa?
- SQL log của use case quan trọng đã được review chưa?

---

## 12. Trả lời nhanh khi phỏng vấn

Câu hỏi: Bạn phát hiện N+1 bằng cách nào?
- Trả lời gọn: bật SQL log/p6spy, đo query count theo từng endpoint và xác nhận bằng integration test.

Câu hỏi: Fetch join hay `@EntityGraph` tốt hơn?
- Trả lời gọn: cả hai đều tốt, chọn theo độ rõ ràng và khả năng maintain; fetch join tường minh trong JPQL, `@EntityGraph` linh hoạt cho fetch plan.

Câu hỏi: Vì sao fetch join collection + pageable nguy hiểm?
- Trả lời gọn: vì join làm nhân bản parent rows, dẫn tới phân trang sai và tốn tài nguyên; nên dùng chiến lược 2 bước.

---

## Tổng kết

Task 08 cần nắm chắc 5 điểm:
1. Detect N+1 bằng số liệu thật
2. Chọn đúng kỹ thuật xử lý (`fetch join`, `EntityGraph`, batch fetch)
3. Tách rõ read model (DTO) và write model (entity)
4. Giải đúng bài pagination với data lớn
5. Tuning có đo lường trước/sau

Nắm chắc 5 điểm này, bạn sẽ giảm rõ rệt query thừa và giữ hiệu năng JPA ổn định khi hệ thống tăng tải.