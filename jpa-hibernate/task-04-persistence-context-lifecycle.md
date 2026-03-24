# TASK 04 - Persistence Context và Entity Lifecycle

> Mục tiêu: hiểu đúng vòng đời entity để kiểm soát dirty checking, flush và transaction boundary; tránh bug “khó thấy” khi làm việc với JPA/Hibernate.

---

## 1. Mental Model: Persistence Context là gì?

Persistence Context (PC) là “vùng quản lý entity” của JPA trong một transaction.

Bạn có thể hình dung PC như:
1. Bản đồ theo dõi entity đang được quản lý (managed)
2. Bộ nhớ đệm cấp 1 (L1 cache)
3. Cơ chế so sánh thay đổi để tự sinh SQL (dirty checking)

Hệ quả quan trọng:
- Không phải cứ gọi setter là DB cập nhật ngay.
- SQL thường được đẩy xuống DB ở thời điểm flush/commit.

---

## 2. Vòng đời Entity: 4 trạng thái cốt lõi

## 2.1 Transient
- Object mới tạo bằng `new`, chưa liên quan JPA.
- Chưa có identity trong persistence context.

## 2.2 Managed
- Entity đang được PC quản lý.
- Mọi thay đổi field sẽ được dirty checking theo dõi.

## 2.3 Detached
- Từng là managed, nhưng không còn trong PC (do transaction kết thúc, `clear()`, `detach()`...).
- Thay đổi trên detached entity sẽ không tự động sync DB.

## 2.4 Removed
- Entity được đánh dấu xóa trong PC.
- SQL `DELETE` sẽ được thực thi khi flush/commit.

Sơ đồ chuyển trạng thái thường gặp:
- `new` -> `persist()` -> managed
- managed -> `detach()` / `clear()` -> detached
- detached -> `merge()` -> managed (bản sao managed)
- managed -> `remove()` -> removed

---

## 3. Dirty Checking: cơ chế mạnh nhất nhưng dễ bị hiểu sai

Dirty checking hoạt động khi:
1. Entity ở trạng thái managed
2. Transaction còn mở
3. Đến thời điểm flush

Ví dụ:
- Bạn load `User` trong transaction
- Gọi `user.setName("A")`
- Không cần gọi `save()` trong pure JPA
- Khi commit, Hibernate tự phát hiện thay đổi và generate `UPDATE`

Lưu ý:
- Dirty checking không chạy cho detached entity.
- Thay đổi trong object graph lớn có thể phát sinh nhiều SQL nếu không kiểm soát tốt.

---

## 4. `flush()`, `clear()`, `detach()`: khác nhau thế nào?

## 4.1 `flush()`
- Đồng bộ thay đổi từ PC xuống DB ngay lập tức (nhưng transaction có thể chưa commit).
- Dùng khi:
  - Cần phát hiện lỗi constraint sớm
  - Cần dữ liệu vừa ghi để query tiếp trong cùng transaction

## 4.2 `clear()`
- Xóa toàn bộ entity khỏi PC.
- Sau `clear()`, tất cả entity trước đó trở thành detached.
- Dùng khi:
  - Batch processing để tránh phình memory

## 4.3 `detach(entity)`
- Tách một entity cụ thể khỏi PC.
- Dùng khi cần bỏ theo dõi một object riêng lẻ.

Quy tắc nhớ nhanh:
- `flush()` = đẩy SQL
- `clear()` = quên toàn bộ
- `detach()` = quên một đối tượng

---

## 5. `persist()` vs `merge()`: câu hỏi phỏng vấn rất hay gặp

## 5.1 `persist(entity)`
- Dành cho entity mới (transient).
- Sau khi persist, chính object đó trở thành managed.

## 5.2 `merge(entity)`
- Thường dùng cho detached entity.
- Hibernate trả về một bản managed mới; object truyền vào vẫn detached.

Pitfall kinh điển:
- Gọi `merge(detached)` rồi tiếp tục sửa object detached cũ và nghĩ rằng DB sẽ cập nhật.
- Đúng phải sửa object trả về từ `merge()`.

Ví dụ đúng:
```java
User managed = entityManager.merge(detachedUser);
managed.setDisplayName("new-name");
```

Khuyến nghị thực tế:
- Luồng cập nhật trong transaction nên load entity managed rồi sửa trực tiếp.
- Hạn chế lạm dụng merge nếu có thể thiết kế luồng rõ hơn.

---

## 6. Transaction boundary trong Spring: vì sao nên đặt ở service?

Trong Spring Boot, persistence context thường gắn với transaction.

Khuyến nghị:
- Đặt `@Transactional` ở service layer.
- Controller chỉ nhận request/response, không chứa logic data access.

Lý do:
1. Dễ kiểm soát vòng đời entity
2. Tránh lazy load ngoài transaction
3. Rõ ràng về consistency và rollback

---

## 7. Flush timing và write-behind khi commit

JPA/Hibernate thường dùng transactional write-behind:
- Entity thay đổi trong memory trước
- SQL đẩy xuống lúc flush/commit

Thứ tự SQL khi commit còn phụ thuộc:
- Quan hệ entity
- FK constraints
- Batch setting

Do đó, đừng giả định thứ tự SQL theo thứ tự gọi setter trong code.

---

## 8. Mẫu service chuẩn (đơn giản, an toàn)

```java
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional
    public void updateProfile(Long userId, String displayName) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        user.setDisplayName(displayName);
        // Không cần gọi save trong nhiều trường hợp vì dirty checking sẽ tự update khi commit.
    }
}
```

---

## 9. Lỗi phổ biến và cách tránh

1. Sửa detached entity và chờ auto update
- Hậu quả: không có SQL update
- Cách tránh: đảm bảo entity đang managed hoặc dùng merge đúng cách

2. Lạm dụng `clear()` trong luồng nghiệp vụ thường
- Hậu quả: mất context quản lý, sinh bug khó đoán
- Cách tránh: chỉ dùng clear cho batch/stream lớn

3. Gọi `flush()` quá sớm/quá thường xuyên
- Hậu quả: mất lợi ích batching, giảm hiệu năng
- Cách tránh: chỉ flush khi có lý do rõ ràng

4. Đặt `@Transactional` ở controller
- Hậu quả: boundary không sạch, khó bảo trì
- Cách tránh: chuyển transaction về service

5. Hiểu sai `merge()` trả về object nào là managed
- Hậu quả: update không như mong đợi
- Cách tránh: luôn thao tác trên instance trả về từ merge

---

## 10. Checklist trước khi merge code

- Luồng create dùng `persist`/`save` cho entity mới
- Luồng update thao tác trên managed entity trong transaction
- Đã xác định rõ chỗ cần `flush()` (nếu có)
- Không có business flow phụ thuộc vào detached entity ngoài ý muốn
- `@Transactional` đặt ở service layer
- Có test cho case update để xác nhận dirty checking chạy đúng

---

## 11. Trả lời nhanh khi phỏng vấn

Câu hỏi: Vì sao thay đổi entity không gọi save vẫn update DB?
- Trả lời gọn: vì entity đang managed, Hibernate dirty checking và flush khi commit.

Câu hỏi: `persist` khác `merge` thế nào?
- Trả lời gọn: `persist` dùng cho entity mới và chính object đó thành managed; `merge` dùng cho detached và trả về bản managed mới.

Câu hỏi: `flush` và `commit` khác gì?
- Trả lời gọn: `flush` đẩy SQL xuống DB nhưng chưa kết thúc transaction; `commit` chốt transaction và xác nhận thay đổi.

---

## Tổng kết

Task 04 cần nắm chắc 4 năng lực:
1. Hiểu vòng đời entity (transient, managed, detached, removed)
2. Vận dụng đúng dirty checking
3. Phân biệt rõ `flush()`, `clear()`, `detach()`, `persist()`, `merge()`
4. Thiết kế transaction boundary đúng ở service

Nắm chắc các điểm này sẽ giúp bạn kiểm soát tốt hành vi runtime của JPA/Hibernate và tránh nhiều lỗi production khó truy vết.