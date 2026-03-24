# TASK 02 - Quan hệ One/Many (Owning Side và Cascade)

> Mục tiêu: Mapping đúng quan hệ để tránh duplicate row, orphan rác, và các lỗi khó debug trong production.

---

## 1. Tư duy nền tảng (Mental model)

Trong JPA, quan hệ One-To-Many / Many-To-One có 2 lớp:

1. Lớp object trong Java (Entity A giữ reference đến Entity B)
2. Lớp dữ liệu trong DB (foreign key nằm ở bảng many-side)

Quy tắc quan trọng nhất:
- Foreign key nằm ở bảng con (many-side)
- Vì vậy, bên many-side thường là owning side trong JPA

Nếu map sai owning side, bạn sẽ gặp:
- Update FK không như kỳ vọng
- Phát sinh SQL thừa
- Dữ liệu quan hệ không đồng bộ với object graph

---

## 2. Owning side là gì? `mappedBy` dùng như thế nào?

### 2.1 Định nghĩa
- Owning side: Bên sở hữu quan hệ trong JPA, quyết định cột FK được ghi như thế nào.
- Inverse side: Bên còn lại, chỉ dùng để đọc/hiển thị quan hệ; không điều khiển FK.

### 2.2 Quy tắc thực chiến
- Với cặp One-To-Many / Many-To-One:
  - Many-To-One là owning side
  - One-To-Many đặt `mappedBy` để trỏ ngược về field owning side

### 2.3 Ví dụ đúng

Entity `Order` (1) và `OrderItem` (N):
- `OrderItem` có cột `order_id` -> owning side
- `Order` là inverse side với `mappedBy = "order"`

### 2.4 Helper method bắt buộc nên có

Thêm method để đồng bộ hai chiều object graph:
- `addItem(item)`:
  - `items.add(item)`
  - `item.setOrder(this)`
- `removeItem(item)`:
  - `items.remove(item)`
  - `item.setOrder(null)`

Nếu không đồng bộ hai chiều, object trong bộ nhớ và SQL sinh ra có thể lệch nhau.

---

## 3. `@JoinColumn` vs `@JoinTable`

### 3.1 `@JoinColumn`
Dùng cho quan hệ thông thường One-To-Many / Many-To-One.

Ưu điểm:
- Schema gọn
- Query nhanh hơn trong nhiều trường hợp
- Đúng với thiết kế FK truyền thống

### 3.2 `@JoinTable`
Thường dùng cho Many-To-Many, hoặc One-To-Many đặc biệt khi bạn muốn tách bảng liên kết.

Nhược điểm:
- Thêm một bảng trung gian
- Tăng độ phức tạp query và migration

Kết luận nhanh:
- One-To-Many thông thường: ưu tiên `@JoinColumn`
- Chỉ dùng `@JoinTable` khi có lý do nghiệp vụ/kỹ thuật rõ ràng

---

## 4. Cascade - Truyền hành vi giữa các entity

Cascade không phải là "tự động lưu hết"; nó chỉ định nghĩa hành vi nào sẽ được lan truyền từ parent sang child.

### 4.1 Ý nghĩa các loại cascade

- `PERSIST`:
  - Khi lưu parent mới, child mới cũng được persist.
  - Dùng cho aggregate có vòng đời cùng nhau.

- `MERGE`:
  - Khi merge parent detached, child detached cũng được merge.

- `REMOVE`:
  - Xóa parent sẽ xóa child.
  - Rất nguy hiểm nếu dùng rộng rãi.

- `DETACH`:
  - Tách parent khỏi persistence context thì child cũng detach.

- `REFRESH`:
  - Refresh parent thì child refresh theo.

- `ALL`:
  - Bao gồm toàn bộ bên trên.
  - Không nên dùng mặc định cho mọi quan hệ.

### 4.2 Nguyên tắc an toàn

- Nên bắt đầu từ tập nhỏ: `PERSIST`, `MERGE`
- Cân nhắc rất kỹ trước khi dùng `REMOVE`/`ALL`
- Chỉ cascade theo aggregate boundary (domain-driven design)

---

## 5. `orphanRemoval` - Xóa "con bị bỏ rơi"

### 5.1 `orphanRemoval = true` có nghĩa gì?

Khi child bị loại khỏi collection của parent, JPA sẽ xóa child khỏi DB (`DELETE`), không chỉ set FK = `null`.

### 5.2 Khi nên dùng

- Child không có ý nghĩa tồn tại độc lập với parent
- Ví dụ: `Order` và `OrderItem` (item không sống độc lập khi order thay đổi)

### 5.3 `orphanRemoval` khác `REMOVE` cascade thế nào?

- `orphanRemoval`:
  - Trigger khi child bị gỡ ra khỏi collection
- `CascadeType.REMOVE`:
  - Trigger khi xóa parent

Thường trong aggregate chặt, có thể dùng cả hai (nhưng phải hiểu rõ hành vi).

---

## 6. Chọn `List` hay `Set` cho collection?

### 6.1 `List`

Ưu điểm:
- Giữ thứ tự
- Hợp với UI cần ordering

Lưu ý:
- Nếu cần thứ tự ổn định ở DB, dùng thêm `@OrderColumn` hoặc `ORDER BY` rõ ràng
- Có thể có duplicate theo `equals/hashCode`

### 6.2 `Set`

Ưu điểm:
- Tránh duplicate theo `equals/hashCode`
- Tốt cho quan hệ không quan tâm thứ tự

Lưu ý:
- Bắt buộc `equals/hashCode` đúng, nếu sai sẽ gây bug khó tìm

### 6.3 Chốt lựa chọn nhanh

- Cần thứ tự hiển thị: `List`
- Cần uniqueness và không cần thứ tự: `Set`

---

## 7. Mẫu code tham khảo (rút gọn)

```java
@Entity
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToMany(mappedBy = "order", cascade = {CascadeType.PERSIST, CascadeType.MERGE}, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();

    public void addItem(OrderItem item) {
        items.add(item);
        item.setOrder(this);
    }

    public void removeItem(OrderItem item) {
        items.remove(item);
        item.setOrder(null);
    }
}

@Entity
@Table(name = "order_items")
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;
}
```

---

## 8. Lỗi phổ biến và cách tránh

1. Đặt `mappedBy` sai tên field
- Triệu chứng: app start fail, lỗi mapping
- Cách tránh: tên `mappedBy` phải trùng tuyệt đối với field owning side

2. Chỉ sửa một phía quan hệ
- Triệu chứng: object graph và DB lệch nhau
- Cách tránh: bắt buộc helper method add/remove

3. Lạm dụng `CascadeType.ALL`
- Triệu chứng: xóa dây chuyền ngoài ý muốn
- Cách tránh: mở từng cascade type theo nghiệp vụ

4. Dùng `EAGER` trên many-side không cần thiết
- Triệu chứng: N+1, query nặng
- Cách tránh: để `LAZY`, fetch có chủ đích trong query

5. Dùng `Set` mà `equals/hashCode` sai
- Triệu chứng: duplicate ảo, remove không được
- Cách tránh: thiết kế `equals/hashCode` ổn định, ưu tiên business key bất biến hoặc id đã sinh

---

## 9. Checklist trước khi merge code

- Đã xác định đúng owning side (thường là many-side)
- One-side đã đặt `mappedBy` đúng field tên
- Có helper method đồng bộ hai chiều
- Cascade không dùng `ALL` một cách mù quáng
- `orphanRemoval` phù hợp vòng đời nghiệp vụ
- Collection type (`List`/`Set`) phù hợp use case
- SQL log đã được review để tránh query bất thường

---

## 10. Trả lời nhanh trong phỏng vấn

Câu hỏi: Owning side là gì?
- Trả lời gọn: Bên sở hữu FK trong JPA, bên này quyết định update quan hệ; với One/Many thì many-side thường là owning side.

Câu hỏi: Khi nào dùng `orphanRemoval`?
- Trả lời gọn: Khi child thuộc vòng đời chặt của parent; bỏ child khỏi collection thì child phải bị xóa khỏi DB.

Câu hỏi: `JoinColumn` hay `JoinTable` cho One-To-Many?
- Trả lời gọn: `JoinColumn` là lựa chọn mặc định cho schema gọn và dễ tối ưu; `JoinTable` chỉ dùng khi cần bảng liên kết vì lý do đặc thù.

---

## Tổng kết

Task 02 xoay quanh 3 điểm cốt lõi:
1. Map đúng owning side để FK vận hành chuẩn
2. Dùng cascade có kiểm soát theo aggregate
3. Chọn đúng `orphanRemoval` và collection type để tránh bug dữ liệu

Nếu nắm chắc 3 điểm này, bạn đã vượt qua phần lớn câu hỏi mapping One/Many trong phỏng vấn và giảm rõ rệt bug production.