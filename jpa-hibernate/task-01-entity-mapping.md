# TASK 01 - Entity Mapping Nền Tảng (Ôn Nhanh)

> Mục tiêu: nắm chắc cách ánh xạ class <-> table đúng chuẩn để tránh lỗi key/column, giảm bug runtime và tự tin trả lời phỏng vấn.

---

## 1. Mental Model: Entity Mapping thực chất là gì?

Entity mapping là quy ước chuyển đổi giữa:
1. Mô hình object trong Java
2. Mô hình bảng trong CSDL

Bạn cần đảm bảo 3 điểm luôn đúng:
- Đúng định danh (ID)
- Đúng kiểu dữ liệu/cột
- Đúng ràng buộc (nullable, unique, length...)

Nếu sai 1 trong 3, lỗi thường xuất hiện ở production dưới dạng:
- Dữ liệu sai định dạng hoặc sai enum
- SQL lỗi do constraint
- Query khó tối ưu vì schema không phản ánh đúng domain

---

## 2. Nền tảng bắt buộc: `@Entity` và `@Table`

### 2.1 `@Entity`
- Đánh dấu class là thực thể JPA.
- Class nên có no-args constructor (public/protected).
- Không nên gán business logic nặng vào entity.

### 2.2 `@Table`
- Dùng khi cần chỉ định rõ tên bảng, schema, unique constraints, index.
- Nếu không khai báo, Hibernate dùng tên mặc định theo naming strategy.

Mẹo thực tế:
- Luôn khai báo tên bảng tường minh ở hệ thống lớn để tránh lệch naming giữa môi trường.

---

## 3. Định danh: `@Id` và `@GeneratedValue`

### 3.1 `@Id`
- Bắt buộc cho mọi entity.
- Khóa chính nên ổn định, không thay đổi theo nghiệp vụ.

### 3.2 Chọn strategy sinh ID

#### `GenerationType.IDENTITY`
- DB tự tăng ID (ví dụ MySQL auto increment).
- Ưu điểm: đơn giản, dễ hiểu.
- Nhược điểm: kém tối ưu batch insert vì phải insert ngay để lấy ID.

#### `GenerationType.SEQUENCE`
- Dùng sequence của DB (PostgreSQL, Oracle...).
- Ưu điểm: hỗ trợ batch insert tốt hơn, có thể tối ưu với `allocationSize`.
- Nhược điểm: cấu hình phức tạp hơn IDENTITY một chút.

### 3.3 Quy tắc chọn nhanh
- Dự án cần insert khối lượng lớn: ưu tiên `SEQUENCE`.
- Dự án nhỏ, đơn giản, DB kiểu MySQL: `IDENTITY` vẫn ổn.

---

## 4. Mapping cột: `@Column` và `@Enumerated`

## 4.1 `@Column`
Các thuộc tính dùng nhiều nhất:
- `name`: tên cột trong DB
- `nullable`: có cho phép `NULL` không
- `unique`: có ràng buộc unique không
- `length`: độ dài chuỗi
- `insertable`, `updatable`: kiểm soát ghi dữ liệu

Nguyên tắc:
- Mọi ràng buộc quan trọng của domain nên phản ánh xuống DB, không chỉ validate ở Java.

## 4.2 `@Enumerated`

### `EnumType.ORDINAL`
- Lưu số thứ tự enum (0, 1, 2...).
- Rủi ro cao: đổi thứ tự enum là vỡ dữ liệu cũ.

### `EnumType.STRING`
- Lưu tên enum dạng text.
- An toàn, dễ đọc, dễ migration.

Kết luận:
- Gần như luôn dùng `EnumType.STRING` trong production.

---

## 5. Value Object: `@Embeddable` và `@Embedded`

Khi nhiều field luôn đi cùng nhau (ví dụ `Address`: street, city, zipCode), hãy gom thành value object.

### 5.1 `@Embeddable`
- Đặt trên class value object.

### 5.2 `@Embedded`
- Đặt trên field trong entity để nhúng nhóm cột.

### 5.3 Tránh trùng tên cột
- Nếu nhúng cùng kiểu nhiều lần, dùng `@AttributeOverride(s)` để đổi tên cột.

Lợi ích:
- Code sạch hơn, domain rõ hơn, tái sử dụng tốt hơn.

---

## 6. Khóa tự nhiên: `@NaturalId` (Hibernate)

`@NaturalId` dùng cho thuộc tính có tính định danh ngoài đời thực (email, CCCD, mã SKU...).

Khi nên dùng:
- Thường xuyên tra cứu theo trường unique này.
- Muốn diễn đạt rõ business identity ngoài surrogate key (`id`).

Lợi ích:
- Truy vấn theo natural key rõ nghĩa hơn.
- Hibernate hỗ trợ lookup theo natural id hiệu quả (kèm cache behavior tốt).

Ví dụ:
```java
session.byNaturalId(User.class)
       .using("email", "abc@gmail.com")
       .load();
```

---

## 7. Mẫu entity gợi ý (đủ dùng cho đa số case)

```java
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Long id;

    @NaturalId
    @Column(name = "email", nullable = false, unique = true, length = 255)
    private String email;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private UserStatus status;

    @Embedded
    private Address address;
}
```

---

## 8. Lỗi phổ biến và cách tránh

1. Dùng `ORDINAL` cho enum
- Hậu quả: đổi enum làm sai dữ liệu cũ.
- Cách tránh: dùng `STRING`.

2. Không đặt `nullable = false` cho field bắt buộc
- Hậu quả: dữ liệu rác vào DB.
- Cách tránh: đồng bộ rule ở cả Java validation và DB constraint.

3. Chọn sai strategy sinh ID
- Hậu quả: insert chậm khi batch lớn.
- Cách tránh: ưu tiên `SEQUENCE` khi cần throughput cao.

4. Lạm dụng entity làm DTO
- Hậu quả: mapping rối, khó bảo trì.
- Cách tránh: tách entity và DTO theo mục đích.

---

## 9. Checklist trước khi merge code

- Có `@Entity`, `@Id`, strategy sinh ID rõ ràng
- Field bắt buộc có `nullable = false`
- Enum dùng `EnumType.STRING`
- Value object đã tách bằng `@Embeddable`/`@Embedded` khi phù hợp
- Trường định danh nghiệp vụ có cân nhắc `@NaturalId`
- Schema và domain rule đồng bộ

---

## 10. Trả lời nhanh khi phỏng vấn

Câu hỏi: Khi nào dùng `IDENTITY` và `SEQUENCE`?
- Trả lời gọn: `IDENTITY` đơn giản nhưng không tối ưu batch insert; `SEQUENCE` tối ưu hiệu năng tốt hơn cho hệ thống ghi nhiều.

Câu hỏi: Vì sao tránh `EnumType.ORDINAL`?
- Trả lời gọn: vì thay đổi thứ tự enum sẽ làm lệch dữ liệu lịch sử.

Câu hỏi: `@NaturalId` có thay được `@Id` không?
- Trả lời gọn: không. `@Id` vẫn là PK kỹ thuật; `@NaturalId` bổ sung business identity và tối ưu truy vấn theo khóa tự nhiên.

---

## Tổng kết

Task 01 cần chốt 5 năng lực cốt lõi:
1. Map entity-table chuẩn
2. Chọn đúng chiến lược sinh ID
3. Ràng buộc cột rõ ràng
4. Map enum an toàn
5. Dùng value object và natural id đúng ngữ cảnh

Nắm chắc 5 điểm này, bạn đã có nền tảng vững để đi tiếp sang quan hệ, transaction và performance tuning.
