# Luyện đề tuyển Java Developer phong cách VNPT

Ngày tạo: 2026-03-18

## 1) 15 chủ đề quan trọng nhất cần ôn

1. Java Core nền tảng: JVM, JDK, JRE, stack và heap, pass-by-value, immutable.
2. OOP và tư duy thiết kế: đóng gói, kế thừa, đa hình, trừu tượng, ưu tiên composition.
3. Collection Framework: List, Set, Map, độ phức tạp cơ bản, equals và hashCode.
4. Exception handling: checked và unchecked exception, throw và throws, xử lý lỗi theo tầng.
5. Multithreading cơ bản: Thread, Runnable, synchronized, volatile, race condition, deadlock cơ bản.
6. JDBC cơ bản: Connection, PreparedStatement, transaction, chống SQL Injection.
7. SQL cơ bản đến trung cấp: join, group by, having, subquery, index nền tảng.
8. Spring Boot cơ bản: IoC, DI, Bean, các annotation cốt lõi.
9. REST API: đặt tên tài nguyên, ngữ nghĩa HTTP method, mã trạng thái phù hợp.
10. HTTP nền tảng: request và response, header, cookie, cache, idempotent.
11. Authentication và Authorization cơ bản: session, token, JWT nhập môn, phân quyền theo role.
12. Clean code backend: đặt tên, nguyên tắc trách nhiệm đơn, code smell, refactor cơ bản.
13. Debugging và xử lý lỗi: đọc stack trace, đặt breakpoint, khoanh vùng nguyên nhân.
14. Hiệu năng cơ bản: N+1 query, tạo object không cần thiết, connection pool, nhận diện bottleneck.
15. Git và quy trình làm việc cơ bản: branch, pull request, conflict, commit message rõ ràng.

## 2) Mini test 10 câu trắc nghiệm (độ khó tăng dần)

- Mỗi câu có 4 đáp án A/B/C/D.
- Bạn làm toàn bộ 10 câu và gửi đáp án một lần.
- Mẫu trả lời: `1B, 2A, 3D, 4C, 5B, 6A, 7D, 8C, 9B, 10A`
- Sau khi bạn gửi đáp án: mình sẽ chấm điểm, câu nào sai sẽ đưa gợi ý ngắn trước khi giải thích, rồi phân tích điểm mạnh/yếu và lộ trình ôn tập ưu tiên.

### Câu 1 (Dễ) - Java Core

Trong Java, phát biểu nào đúng về `String`?

A. `String` là mutable nên có thể thay đổi nội dung trực tiếp.
B. `String` là immutable, mỗi thay đổi nội dung sẽ tạo đối tượng mới.
C. `String` luôn nằm trên stack nên truy cập nhanh hơn mọi object khác.
D. Dùng toán tử `==` luôn đúng để so sánh nội dung hai `String`.
### Câu 2 (Dễ) - OOP

Phát biểu nào mô tả đúng tính đa hình (polymorphism)?

A. Một lớp chỉ được phép có một constructor.
B. Một đối tượng có thể được tham chiếu bởi kiểu cha và gọi hành vi đã override.
C. Mọi thuộc tính phải đặt là `private`.
D. Kế thừa giúp tăng tốc độ thực thi chương trình trong mọi trường hợp.
### Câu 3 (Dễ - Trung bình) - Collections

Bạn cần lưu danh sách phần tử **không trùng lặp** và vẫn giữ thứ tự chèn ban đầu. Chọn cấu trúc phù hợp nhất:

A. `HashSet`
B. `TreeSet`
C. `LinkedHashSet`
D. `ArrayList`
### Câu 4 (Trung bình) - Exception

Đâu là thực hành tốt khi xử lý exception ở tầng service?

A. Bắt `Exception` tổng quát ở mọi nơi rồi bỏ qua log cho gọn.
B. Chỉ ném `RuntimeException` để đỡ khai báo `throws`.
C. Bắt exception đủ cụ thể, bổ sung ngữ cảnh và chuyển đổi sang exception nghiệp vụ phù hợp.
D. Luôn trả về `null` thay vì ném exception.
### Câu 5 (Trung bình) - Multithreading

Từ khóa nào đảm bảo **tính nhìn thấy (visibility)** giữa các thread cho một biến đơn giản?

A. `static`
B. `volatile`
C. `final`
D. `transient`
### Câu 6 (Trung bình) - JDBC và SQL

Lý do chính nên dùng `PreparedStatement` thay vì nối chuỗi SQL thủ công là gì?

A. Tự động đóng kết nối database.
B. Ngăn SQL Injection tốt hơn và tái sử dụng câu lệnh hiệu quả.
C. Bắt buộc phải dùng trong mọi truy vấn `SELECT`.
D. Luôn nhanh hơn `Statement` trong mọi trường hợp tuyệt đối.
### Câu 7 (Trung bình - Khá) - REST và HTTP

Với API `/users/{id}`, khi cập nhật toàn bộ thông tin người dùng theo hướng idempotent, method phù hợp nhất là:

A. `POST`
B. `PATCH`
C. `PUT`
D. `GET`
### Câu 8 (Khá) - Spring Boot

Trong Spring Boot, annotation nào thường dùng để đánh dấu class xử lý request HTTP theo mô hình REST và tự động serialize JSON?

A. `@Component`
B. `@RestController`
C. `@Configuration`
D. `@Repository`
### Câu 9 (Khá - Nâng cao) - Authentication/Authorization

Phát biểu nào đúng nhất về Authentication và Authorization?

A. Authentication là kiểm tra quyền truy cập, Authorization là xác thực danh tính.
B. Cả hai là một, chỉ khác tên gọi ở từng framework.
C. Authentication xác minh bạn là ai, Authorization quyết định bạn được làm gì.
D. Chỉ cần Authentication, không cần Authorization trong hệ thống nội bộ.
### Câu 10 (Nâng cao) - Debugging, Hiệu năng, Git

Trong một service Spring Boot, API trả về danh sách đơn hàng chậm bất thường. Sau khi kiểm tra log SQL, bạn thấy khi lấy 100 đơn hàng thì phát sinh thêm hàng trăm truy vấn lấy chi tiết từng đơn (N+1 query). Hành động nào hợp lý nhất trước tiên?

A. Tăng CPU server ngay để xử lý nhanh hơn.
B. Bỏ hết log SQL để giảm thời gian ghi log.
C. Rà soát mapping quan hệ và tối ưu truy vấn (fetch join/entity graph/projection) để giảm số round-trip DB.
D. Tạo thêm branch Git mới rồi merge vào `main` để tối ưu dần.
## 3) Gửi đáp án

Đáp án: `1B, 2B, 3B, 4C, 5B, 6B, 7C, 8B, 9C, 10C`

## 4) Chấm điểm và chữa bài

### Kết quả tổng

- Điểm: **9/10**
- Đúng: 9 câu
- Sai: 1 câu (Câu 3)

### Chữa câu sai

#### Câu 3 - Collections

- Đáp án bạn chọn: **B (`TreeSet`)**
- Đáp án đúng: **C (`LinkedHashSet`)**

Gợi ý:
- Hãy chọn cấu trúc vừa loại bỏ phần tử trùng, vừa giữ nguyên thứ tự chèn ban đầu.

Giải thích:
- `LinkedHashSet` loại bỏ phần tử trùng và vẫn giữ thứ tự chèn.
- `HashSet` loại bỏ trùng nhưng không đảm bảo thứ tự.
- `TreeSet` loại bỏ trùng nhưng sắp xếp theo thứ tự tự nhiên/comparator, không giữ thứ tự chèn.
- `ArrayList` giữ thứ tự chèn nhưng cho phép trùng lặp.

### Đáp án chuẩn của đề

`1B, 2B, 3C, 4C, 5B, 6B, 7C, 8B, 9C, 10C`

### Kiến thức cần ôn lại ưu tiên

1. Phân biệt chuyên sâu `HashSet`, `LinkedHashSet`, `TreeSet`.
2. Độ phức tạp thao tác thêm/tìm/xóa của từng collection.
3. `equals` và `hashCode` khi dùng object trong Set/Map.