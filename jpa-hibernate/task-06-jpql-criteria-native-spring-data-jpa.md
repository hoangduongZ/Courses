# TASK 06 - JPQL, Criteria, Native (Spring Data JPA)

> Mục tiêu: viết query sạch, đúng ngữ cảnh, tránh lỗi runtime và tối ưu khả năng bảo trì khi dùng Spring Data JPA.

---

## 1. Mental Model: chọn công cụ query theo bài toán

Trong JPA, bạn có 3 nhóm công cụ chính:
1. JPQL: dễ đọc, bám theo mô hình entity
2. Criteria API: type-safe, phù hợp query động
3. Native SQL: tối ưu cao, tận dụng sức mạnh DB đặc thù

Quy tắc chọn nhanh:
- Query đơn giản hoặc trung bình: ưu tiên JPQL
- Query động nhiều điều kiện: ưu tiên Criteria/Specification
- Query cực nặng hoặc cần DB-specific function/hint: cân nhắc Native

---

## 2. JPQL: ngôn ngữ truy vấn theo entity

JPQL truy vấn trên entity/field, không truy vấn trực tiếp tên bảng/cột vật lý.

Ví dụ:
```jpql
select o
from Order o
where o.status = :status
order by o.createdAt desc
```

Ưu điểm:
- Đọc gần domain model
- Dễ tích hợp với Spring Data `@Query`

Nhược điểm:
- Một số tối ưu đặc thù DB khó thể hiện đầy đủ

---

## 3. Fetch Join trong JPQL: mạnh nhưng cần kỷ luật

Ví dụ:
```jpql
select o
from Order o
join fetch o.customer
where o.status = :status
```

Khi nên dùng:
- Chắc chắn use case cần luôn association đó
- Muốn giảm N+1 trên luồng đọc

Cảnh báo:
- Fetch join với collection + pagination dễ sai kết quả hoặc duplicate
- Không lạm dụng nhiều fetch join sâu trong một query

---

## 4. Pagination đúng: tách data query và count query

Với query phức tạp, luôn nghĩ theo 2 phần:
1. Query lấy dữ liệu trang hiện tại
2. Query đếm tổng (`count query`) đơn giản hóa tối đa

Ví dụ Spring Data:
```java
@Query(
    value = "select o from Order o where o.status = :status",
    countQuery = "select count(o.id) from Order o where o.status = :status"
)
Page<Order> findPageByStatus(@Param("status") OrderStatus status, Pageable pageable);
```

Nguyên tắc:
- Count query không cần `fetch join`
- Tránh `order by` không cần thiết trong count query

---

## 5. Criteria API: type-safe cho query động

Khi filter có nhiều tổ hợp điều kiện (search màn hình admin, báo cáo...), Criteria giúp:
- Tránh nối chuỗi SQL/JPQL thủ công
- Tái sử dụng predicate tốt hơn

Ví dụ tư duy:
- Nếu người dùng nhập `name`, thêm predicate `like`
- Nếu có `status`, thêm predicate `equal`
- Nếu có khoảng ngày, thêm predicate `between`

Ưu điểm:
- An toàn kiểu dữ liệu
- Tốt cho query động và DSL nội bộ

Nhược điểm:
- Verbose, đọc kém trực quan hơn JPQL

---

## 6. Native Query: dùng khi thật sự cần

Khi nên dùng Native:
- Cần CTE/window function/hint đặc thù DB
- Cần tối ưu plan theo SQL thuần
- Cần truy vấn vào view/materialized view phức tạp

Cái giá phải trả:
- Mất tính portable giữa DB
- Mapping kết quả phức tạp hơn
- Dễ lệch với model nếu schema đổi

---

## 7. Mapping kết quả Native: scalar vs entity vs DTO

## 7.1 Scalar mapping
- Trả về từng cột (`Object[]` hoặc interface projection)
- Linh hoạt nhưng dễ sai thứ tự cột nếu không cẩn thận

## 7.2 Entity mapping
- Trả về entity khi select đủ cột cần thiết
- Dễ dùng nhưng không hợp cho query tổng hợp nhiều bảng dạng báo cáo

## 7.3 DTO mapping (`SqlResultSetMapping` hoặc projection)
- Tối ưu cho API đọc
- Giảm dữ liệu dư thừa

Khuyến nghị:
- Endpoint đọc danh sách/summary: ưu tiên DTO projection
- Endpoint thao tác domain đầy đủ: entity

---

## 8. Parameter Binding và SQL Injection

Luôn dùng parameter binding:
- Named param: `:status`, `:fromDate`
- Positional param: `?1`, `?2`

Ví dụ an toàn:
```java
@Query("select u from User u where u.email = :email")
Optional<User> findByEmail(@Param("email") String email);
```

Tuyệt đối tránh:
- Nối chuỗi trực tiếp từ input người dùng vào query

Kết luận:
- JPQL có thể giảm rủi ro injection khi bind đúng
- Native vẫn an toàn nếu bind param đúng cách

---

## 9. Spring Data JPA: các pattern query chính

## 9.1 Derived Query Methods
Ví dụ:
```java
List<Order> findByStatusAndCreatedAtBetween(OrderStatus status, Instant from, Instant to);
```

Ưu điểm:
- Nhanh, ít boilerplate

Nhược điểm:
- Tên method dài và khó đọc khi điều kiện phức tạp

## 9.2 `@Query`
Dùng khi cần viết rõ JPQL/Native cho nghiệp vụ cụ thể.

Ví dụ:
```java
@Query("select o from Order o where o.totalAmount >= :min")
List<Order> findExpensiveOrders(@Param("min") BigDecimal min);
```

## 9.3 `@Modifying`
Dùng cho update/delete query trực tiếp.

Ví dụ:
```java
@Modifying(clearAutomatically = true, flushAutomatically = true)
@Query("update User u set u.status = :status where u.lastLogin < :cutoff")
int deactivateInactiveUsers(@Param("status") UserStatus status, @Param("cutoff") Instant cutoff);
```

Lưu ý:
- `@Modifying` cần chạy trong transaction
- Bulk update bỏ qua lifecycle callback và có thể bypass persistence context hiện tại

---

## 10. Projection: interface-based vs DTO constructor

## 10.1 Interface-based projection

Ví dụ:
```java
public interface OrderSummary {
    Long getId();
    String getCustomerName();
    BigDecimal getTotalAmount();
}
```

Ưu điểm:
- Viết nhanh
- Giảm lượng dữ liệu trả về

## 10.2 DTO constructor projection

Ví dụ:
```jpql
select new com.example.dto.OrderSummaryDto(o.id, c.name, o.totalAmount)
from Order o
join o.customer c
```

Ưu điểm:
- Tường minh, ổn định, dễ refactor có kiểm soát

Khuyến nghị:
- API đọc: projection/DTO
- Business flow cần tracking trạng thái entity: entity

---

## 11. Lỗi phổ biến và cách tránh

1. Dùng fetch join + pageable trực tiếp trên collection
- Hậu quả: duplicate/sai phân trang
- Cách tránh: chiến lược 2 bước (page ID trước, load chi tiết sau)

2. Dùng Native cho mọi thứ
- Hậu quả: khó bảo trì, phụ thuộc DB
- Cách tránh: chỉ dùng Native cho điểm thật sự cần

3. Không tách count query
- Hậu quả: pagination chậm hoặc sai
- Cách tránh: luôn khai báo count query riêng cho query phức tạp

4. Nối chuỗi query từ input
- Hậu quả: rủi ro injection
- Cách tránh: bind parameter 100%

5. Lạm dụng entity cho API read-only
- Hậu quả: kéo dữ liệu dư, dễ N+1
- Cách tránh: dùng DTO/interface projection

---

## 12. Checklist trước khi merge code

- Query đã chọn đúng công cụ (JPQL/Criteria/Native) theo use case chưa?
- Có tách data query và count query cho pagination chưa?
- Toàn bộ input đã bind parameter chưa?
- Có dùng projection cho luồng đọc để giảm dữ liệu dư chưa?
- Nếu dùng `@Modifying`, đã xử lý transaction và context sync chưa?
- Có test query quan trọng với dữ liệu thực tế (khối lượng vừa/lớn) chưa?

---

## 13. Trả lời nhanh khi phỏng vấn

Câu hỏi: Khi nào dùng Criteria thay vì JPQL?
- Trả lời gọn: khi query động nhiều điều kiện và cần type-safe, tái sử dụng predicate tốt.

Câu hỏi: Native query có xấu không?
- Trả lời gọn: không xấu; chỉ nên dùng khi cần tối ưu hoặc tính năng DB đặc thù mà JPQL khó đáp ứng.

Câu hỏi: Vì sao pagination cần count query riêng?
- Trả lời gọn: để tránh query đếm bị kéo theo join/fetch không cần thiết, giúp đúng và nhanh hơn.

---

## Tổng kết

Task 06 cần nắm chắc 5 điểm:
1. Chọn đúng công cụ query theo ngữ cảnh
2. Viết pagination chuẩn với count query tách
3. Dùng binding để an toàn injection
4. Ưu tiên projection cho luồng đọc
5. Dùng Native có kiểm soát, không lạm dụng

Nắm chắc các điểm này giúp bạn viết query sạch, ổn định, và dễ tối ưu khi hệ thống tăng tải.