# TASK 09 - Pagination, Sorting, Specifications

> Mục tiêu: paginate đúng và ổn định khi dữ liệu lớn, tránh lỗi hiệu năng; trả lời tốt các câu hỏi về `Pageable`, `Slice`, `Sort` và query động bằng Specification.

---

## 1. Mental Model: phân trang là bài toán tính đúng + chạy nhanh

Phân trang tốt phải đảm bảo đồng thời:
1. Đúng dữ liệu theo thứ tự ổn định
2. Đúng tổng số bản ghi (nếu cần)
3. Tốc độ chấp nhận được khi dữ liệu tăng

Sai lầm thường gặp:
- Chỉ nghĩ về UI page 1, page 2 mà quên tính ổn định của `ORDER BY`
- Dùng một query phức tạp cho cả data và count
- Offset quá lớn gây chậm nặng

---

## 2. Nền tảng SQL/JPA: `setFirstResult` và `setMaxResults`

Trong JPA, phân trang cốt lõi dựa trên:
- `setFirstResult(offset)`
- `setMaxResults(limit)`

Spring Data đã bọc logic này qua `Pageable`.

Điểm cần nhớ:
- Offset pagination vẫn phải scan/bỏ qua nhiều dòng khi page sâu
- Cần chỉ mục (index) phù hợp với cột `ORDER BY` và điều kiện lọc

---

## 3. Count Query: tách riêng để đúng và nhanh

Với query có join/phức tạp, nên tách:
1. Data query
2. Count query đơn giản hơn

Ví dụ Spring Data:
```java
@Query(
    value = "select o from Order o where o.status = :status",
    countQuery = "select count(o.id) from Order o where o.status = :status"
)
Page<Order> findPageByStatus(@Param("status") OrderStatus status, Pageable pageable);
```

Nguyên tắc:
- Count query không cần fetch join
- Tránh `order by` trong count
- Tránh `count(*)` trên join dư thừa nếu có thể

---

## 4. Offset vs Cursor Pagination

## 4.1 Offset pagination

Ưu điểm:
- Dễ dùng, hỗ trợ nhảy trang trực tiếp
- Tích hợp sẵn với `Pageable`

Nhược điểm:
- Page sâu chậm dần
- Dễ lệch dữ liệu khi có insert/delete giữa các lần đọc

## 4.2 Cursor (keyset) pagination

Ý tưởng:
- Không dùng offset lớn
- Lấy trang kế tiếp theo mốc khóa cuối cùng (ví dụ `createdAt`, `id`)

Ưu điểm:
- Nhanh hơn khi dữ liệu lớn và cuộn vô hạn
- Ổn định hơn dưới tải ghi cao

Nhược điểm:
- Khó nhảy trực tiếp tới trang bất kỳ

Chọn nhanh:
- Backoffice cần nhảy trang: offset
- Feed/list lớn kiểu infinite scroll: cursor

---

## 5. `ORDER BY` ổn định: bắt buộc cho phân trang đúng

Một page chỉ ổn định khi thứ tự sắp xếp là xác định duy nhất.

Khuyến nghị:
- Luôn thêm tie-breaker, ví dụ:
  - `order by createdAt desc, id desc`

Nếu chỉ `order by createdAt desc`:
- Các dòng cùng timestamp có thể đảo vị trí giữa các lần truy vấn
- Dẫn tới trùng/mất bản ghi khi sang trang

---

## 6. Spring Data `Page`, `Slice`, `Sort`: dùng sao cho đúng

## 6.1 `Page<T>`
- Có tổng số phần tử và tổng số trang
- Tốn thêm query count

Dùng khi:
- UI cần hiện tổng trang/tổng bản ghi

## 6.2 `Slice<T>`
- Không cần count tổng
- Chỉ biết có trang sau hay không

Dùng khi:
- Infinite scroll
- Muốn giảm chi phí count query

## 6.3 `Sort`
- Khai báo tiêu chí sắp xếp linh hoạt
- Cần kiểm soát whitelist field cho API công khai để tránh lạm dụng

---

## 7. Specification Pattern cho query động

Khi bộ lọc linh hoạt (status, keyword, date range...), Specification giúp:
- Tách từng điều kiện thành spec nhỏ
- Kết hợp bằng `and()`/`or()`
- Tái sử dụng cao, dễ test

Ví dụ hướng tiếp cận:
1. `hasStatus(status)`
2. `createdBetween(from, to)`
3. `customerNameLike(keyword)`
4. Ghép lại theo input thực tế

Kết hợp Spring Data:
- `JpaSpecificationExecutor<T>`
- `findAll(spec, pageable)`

---

## 8. Derived Query vs `@Query` với `Pageable`

## 8.1 Derived Query
Ví dụ:
```java
Page<Order> findByStatus(OrderStatus status, Pageable pageable);
```

Ưu điểm:
- Nhanh, ít code

Nhược điểm:
- Khó đọc khi điều kiện dài/phức tạp

## 8.2 `@Query` + `Pageable`

Ưu điểm:
- Chủ động tối ưu JPQL/count query
- Rõ ràng hơn cho case đặc thù

Nhược điểm:
- Tốn công bảo trì hơn derived query đơn giản

Khuyến nghị:
- Query đơn giản: derived
- Query phức tạp/tuning: `@Query` + countQuery tách

---

## 9. Mẫu code tham khảo

## 9.1 Repository với `Page` và `Slice`
```java
public interface OrderRepository extends JpaRepository<Order, Long>, JpaSpecificationExecutor<Order> {

    Page<Order> findByStatus(OrderStatus status, Pageable pageable);

    Slice<Order> findByStatusAndIdLessThanOrderByIdDesc(OrderStatus status, Long lastId, Pageable pageable);
}
```

## 9.2 Specification mẫu
```java
public final class OrderSpecifications {

    private OrderSpecifications() {}

    public static Specification<Order> hasStatus(OrderStatus status) {
        return (root, query, cb) -> status == null ? cb.conjunction() : cb.equal(root.get("status"), status);
    }

    public static Specification<Order> createdBetween(Instant from, Instant to) {
        return (root, query, cb) -> {
            if (from == null && to == null) return cb.conjunction();
            if (from == null) return cb.lessThanOrEqualTo(root.get("createdAt"), to);
            if (to == null) return cb.greaterThanOrEqualTo(root.get("createdAt"), from);
            return cb.between(root.get("createdAt"), from, to);
        };
    }
}
```

---

## 10. Lỗi phổ biến và cách tránh

1. Không có `ORDER BY` ổn định
- Hậu quả: trùng/mất bản ghi giữa các trang
- Cách tránh: thêm tie-breaker (`id`)

2. Lạm dụng `Page` ở mọi nơi
- Hậu quả: count query tốn tài nguyên không cần thiết
- Cách tránh: dùng `Slice` khi chỉ cần next page

3. Offset pagination cho page rất sâu
- Hậu quả: query chậm dần
- Cách tránh: chuyển keyset/cursor cho luồng cuộn dài

4. Query phức tạp nhưng không tách count query
- Hậu quả: chậm và khó tối ưu
- Cách tránh: viết `countQuery` riêng

5. Specification quá “god class”
- Hậu quả: khó đọc, khó test
- Cách tránh: tách spec nhỏ theo từng tiêu chí

---

## 11. Checklist trước khi merge code

- Đã chọn đúng kiểu phân trang (`Page`/`Slice`/cursor) theo use case chưa?
- `ORDER BY` đã ổn định với tie-breaker chưa?
- Count query đã tách và tối giản chưa?
- Có index hỗ trợ điều kiện lọc + sắp xếp chưa?
- Specification đã chia nhỏ, dễ test và tái sử dụng chưa?
- Đã test page sâu (ví dụ page 100+) cho endpoint chính chưa?

---

## 12. Trả lời nhanh khi phỏng vấn

Câu hỏi: Khi nào dùng `Slice` thay vì `Page`?
- Trả lời gọn: khi không cần tổng số bản ghi/tổng trang, chỉ cần biết có trang tiếp theo để giảm chi phí count query.

Câu hỏi: Vì sao cần `ORDER BY` ổn định khi paginate?
- Trả lời gọn: để tránh trùng hoặc mất bản ghi giữa các trang khi dữ liệu thay đổi hoặc khi nhiều dòng cùng giá trị sort.

Câu hỏi: Offset hay cursor tốt hơn?
- Trả lời gọn: offset tiện nhảy trang; cursor nhanh và ổn định hơn cho dữ liệu lớn/infinite scroll.

---

## Tổng kết

Task 09 cần nắm chắc 5 điểm:
1. Phân trang luôn đi kèm thứ tự ổn định
2. Tách count query để giữ hiệu năng
3. Chọn đúng `Page`/`Slice`/cursor theo nhu cầu UI
4. Dùng Specification để quản lý query động có cấu trúc
5. Tuning bằng số liệu thực (page sâu, latency, plan/index)

Nắm chắc các điểm này giúp bạn paginate chính xác, hiệu năng tốt và trả lời thuyết phục trong phỏng vấn JPA/Spring Data.