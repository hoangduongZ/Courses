# TASK 03 - Fetch Strategy và Lazy Pitfalls

> Mục tiêu: nhận diện nhanh N+1 và LazyInitializationException, chọn fetch strategy đúng để vừa đúng dữ liệu vừa tối ưu hiệu năng.

---

## 1. Mental Model: Fetch Strategy là quyết định thời điểm tải dữ liệu

Trong JPA, mapping quan hệ không chỉ là quan hệ dữ liệu, mà còn là chiến lược tải dữ liệu:
1. Tải ngay (eager)
2. Tải khi truy cập (lazy)

Nếu chọn sai, hệ thống thường gặp:
- Query thừa (N+1)
- Query quá nặng do join không kiểm soát
- Lỗi LazyInitializationException ngoài transaction

Nguyên tắc cốt lõi:
- Mapping nên thiên về LAZY
- Việc lấy “đúng dữ liệu cho đúng use case” nên quyết định ở tầng query

---

## 2. LAZY vs EAGER: hiểu đúng mặc định và hệ quả

## 2.1 Mặc định của JPA
- `@ManyToOne`, `@OneToOne`: mặc định `EAGER`
- `@OneToMany`, `@ManyToMany`: mặc định `LAZY`

## 2.2 Vì sao `EAGER` mặc định ở `@ManyToOne` dễ gây vấn đề?
- Khi load danh sách entity cha, mỗi bản ghi có thể kéo thêm entity con không cần thiết
- Dễ tạo query nặng hoặc chuỗi truy vấn khó đoán

Khuyến nghị thực tế:
- Chủ động set `fetch = FetchType.LAZY` cho hầu hết quan hệ, kể cả `@ManyToOne`
- Dùng fetch join hoặc `@EntityGraph` ở nơi thật sự cần dữ liệu liên quan

---

## 3. N+1 Query: nhận diện và cơ chế gây ra

## 3.1 N+1 là gì?
- 1 query lấy danh sách cha
- N query tiếp theo để lấy dữ liệu quan hệ cho từng dòng

Ví dụ:
- Query 1: lấy 100 `Order`
- Query 2..101: mỗi `Order` lại query `Customer`

Kết quả:
- Tăng latency
- Tăng tải DB
- Tăng lock contention khi traffic cao

## 3.2 Cách phát hiện
- Bật SQL log (`hibernate.show_sql`, `hibernate.format_sql`)
- Gắn p6spy hoặc datasource-proxy để xem số lượng query thực tế
- Đo query count trong integration test cho endpoint/repository quan trọng

---

## 4. Công cụ xử lý: Fetch Join, EntityGraph, Batch Fetch

## 4.1 Fetch Join (JPQL)
Dùng khi cần lấy parent + association trong cùng use case, cùng transaction.

Ví dụ:
```jpql
select o from Order o
join fetch o.customer
where o.status = :status
```

Ưu điểm:
- Giảm số query mạnh

Lưu ý:
- Không lạm dụng nhiều fetch join sâu trong cùng query (dễ nổ cartesian product)
- Dễ tạo duplicate row khi join collection

## 4.2 `@EntityGraph`
Dùng khi muốn tách logic fetch khỏi JPQL, giữ query dễ đọc.

Ví dụ:
```java
@EntityGraph(attributePaths = {"customer"})
List<Order> findByStatus(OrderStatus status);
```

Ưu điểm:
- Linh hoạt theo use case đọc
- Dễ maintain hơn query dài

## 4.3 Batch Fetch
Dùng khi bạn chấp nhận lazy, nhưng muốn giảm số query khi truy cập nhiều association cùng loại.

Cấu hình điển hình:
```properties
spring.jpa.properties.hibernate.default_batch_fetch_size=50
```

Cơ chế:
- Hibernate gom nhiều lazy proxy và load theo lô (IN clause)

Khi phù hợp:
- Màn hình list truy cập lặp vào một association lazy
- Không muốn dùng fetch join vì pagination/độ phức tạp query

## 4.4 Subselect Fetch
Một số tình huống collection có thể hưởng lợi từ fetch mode subselect.

Ưu điểm:
- Giảm số query khi duyệt collection của nhiều parent vừa load

Nhược điểm:
- Không phải lúc nào cũng tốt; cần benchmark theo dữ liệu thực

---

## 5. LazyInitializationException: vì sao xảy ra?

Lỗi xuất hiện khi:
- Entity đã detached hoặc transaction đã đóng
- Bạn mới truy cập thuộc tính lazy sau đó

Pattern thường gặp:
- Service trả entity ra controller
- Controller/Jackson truy cập field lazy ngoài transaction

Cách xử lý đúng:
1. Tải đủ dữ liệu trong service (fetch join / entity graph / DTO projection)
2. Trả DTO thay vì trả entity trực tiếp ra API
3. Giữ transaction boundary rõ ràng ở service layer

Không khuyến khích:
- “Chữa cháy” bằng cách đổi tất cả sang EAGER

---

## 6. OpenEntityManagerInView (OSIV): bật hay tắt?

## 6.1 OSIV bật
- Session/EntityManager còn mở tới tận view/controller
- Có thể “vô tình” lazy load trong controller

Rủi ro:
- Truy vấn phát sinh ngoài tầng service, khó kiểm soát
- Tăng rủi ro N+1 ở tầng web

## 6.2 OSIV tắt
- Buộc service phải chuẩn bị dữ liệu đầy đủ
- Kiến trúc sạch hơn, dễ kiểm soát truy vấn hơn

Khuyến nghị cho production:
- Ưu tiên tắt OSIV
- Thiết kế rõ read model (DTO/projection/fetch plan) ở service-repository

---

## 7. Khi nào giữ LAZY + truy vấn riêng thay vì fetch join?

Giữ LAZY + truy vấn riêng khi:
- Không phải request nào cũng cần association đó
- Association có kích thước lớn (collection lớn)
- Cần phân trang ổn định trên entity gốc
- Cần kiểm soát tải dữ liệu theo từng bước

Dùng fetch join khi:
- Chắc chắn use case luôn cần association
- Dữ liệu liên quan nhỏ/vừa
- Không xung đột với pagination

---

## 8. Pagination + Fetch Join: pitfall rất hay gặp

Vấn đề:
- Fetch join với collection có thể nhân bản dòng parent
- Pagination trên SQL bị sai ý nghĩa
- `DISTINCT` đôi khi chỉ xử lý ở memory, vẫn tốn tài nguyên

Giải pháp phổ biến:
1. Query trang ID parent trước
2. Query thứ hai lấy dữ liệu chi tiết theo tập ID
3. Map ra DTO

Đây là chiến lược ổn định hơn cho màn hình list lớn.

---

## 9. Mẫu cấu hình và code gợi ý

## 9.1 Cấu hình
```properties
spring.jpa.open-in-view=false
spring.jpa.properties.hibernate.default_batch_fetch_size=50
spring.jpa.properties.hibernate.format_sql=true
```

## 9.2 Repository gợi ý
```java
public interface OrderRepository extends JpaRepository<Order, Long> {

    @EntityGraph(attributePaths = {"customer"})
    Page<Order> findByStatus(OrderStatus status, Pageable pageable);

    @Query("select o from Order o join fetch o.customer where o.id in :ids")
    List<Order> findWithCustomerByIdIn(@Param("ids") List<Long> ids);
}
```

---

## 10. Lỗi phổ biến và cách tránh

1. Để mặc định `EAGER` ở `@ManyToOne`
- Hậu quả: query nặng, khó đoán
- Cách tránh: set `LAZY` chủ động

2. Trả entity trực tiếp ra API
- Hậu quả: LazyInitializationException hoặc query ngầm
- Cách tránh: trả DTO/projection

3. Fetch join collection + pageable trực tiếp
- Hậu quả: sai phân trang, duplicate
- Cách tránh: 2-step query (page ID -> load detail)

4. Tắt SQL log ở giai đoạn tuning
- Hậu quả: không thấy được N+1
- Cách tránh: bật log + theo dõi query count định kỳ

---

## 11. Checklist trước khi merge code

- Quan hệ chính đã đặt `LAZY` chủ động chưa?
- Use case đọc đã có fetch plan rõ (fetch join hoặc entity graph)?
- Có nguy cơ N+1 trên endpoint list không?
- Có dùng DTO/projection thay vì trả entity thẳng ra API không?
- Pagination có tách count/query detail hợp lý không?
- OSIV đã chọn đúng theo kiến trúc dự án chưa?

---

## 12. Trả lời nhanh khi phỏng vấn

Câu hỏi: N+1 là gì và fix sao?
- Trả lời gọn: 1 query lấy danh sách + N query lấy association từng dòng; fix bằng fetch join, entity graph, hoặc batch fetch tùy use case.

Câu hỏi: Vì sao không set EAGER hết cho khỏe?
- Trả lời gọn: EAGER làm query khó kiểm soát và dễ kéo dữ liệu dư; nên để LAZY và quyết định fetch ở query.

Câu hỏi: OSIV nên bật hay tắt?
- Trả lời gọn: production thường nên tắt để kiểm soát truy vấn ở service; dữ liệu trả API nên chuẩn bị đủ trong transaction.

---

## Tổng kết

Task 03 tập trung vào 4 năng lực cốt lõi:
1. Hiểu đúng LAZY/EAGER và mặc định nguy hiểm
2. Nhận diện và xử lý N+1 có hệ thống
3. Chọn công cụ fetch đúng ngữ cảnh (`fetch join`, `@EntityGraph`, batch fetch)
4. Thiết kế boundary dữ liệu đúng (service + DTO + kiểm soát OSIV)

Nắm chắc 4 điểm này sẽ giảm đáng kể lỗi hiệu năng và lỗi lazy load trong hệ thống Spring Data JPA.