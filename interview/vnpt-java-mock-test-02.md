# Luyện đề tuyển Java Developer phong cách VNPT - Đề 2

Ngày tạo: 2026-03-18
Mục tiêu đề 2: Tăng độ khó, tập trung xử lý điểm yếu từ đề 1 (Collections, độ phức tạp thao tác, equals/hashCode) và giữ độ phủ Java Backend thực tế.

## 1) Hướng dẫn làm bài

- Số câu: 10 câu trắc nghiệm.
- Mỗi câu có 4 đáp án A/B/C/D.
- Độ khó tăng dần từ câu 1 đến câu 10.
- Trả lời một lần theo mẫu:
  - 1A, 2B, 3C, 4D, 5A, 6B, 7C, 8D, 9A, 10B

## 2) Câu hỏi

### Câu 1 (Dễ) - Collections

Bạn cần lưu danh sách username không trùng và giữ đúng thứ tự người dùng đăng ký đầu tiên. Chọn cấu trúc phù hợp nhất.

A. HashSet
B. LinkedHashSet
C. TreeSet
D. ArrayList

### Câu 2 (Dễ) - Java Core

Trong Java, phát biểu nào đúng về tham số truyền vào phương thức?

A. Java truyền tham chiếu bằng reference cho object.
B. Java truyền giá trị bằng value cho cả primitive và object reference.
C. Primitive truyền bằng value, object truyền bằng reference.
D. Java chọn cơ chế truyền theo kiểu dữ liệu runtime.

### Câu 3 (Dễ - Trung bình) - Độ phức tạp thao tác

Độ phức tạp trung bình của thao tác contains trên HashSet là:

A. O(1)
B. O(log n)
C. O(n)
D. O(n log n)

### Câu 4 (Trung bình) - equals/hashCode

Khi dùng object tự định nghĩa làm key trong HashMap, thực hành nào đúng?

A. Chỉ override equals là đủ.
B. Chỉ override hashCode là đủ.
C. Nên override cả equals và hashCode nhất quán.
D. Không cần override vì HashMap tự xử lý.

### Câu 5 (Trung bình) - Exception

Trong service gọi repository và external API, cách xử lý lỗi nào hợp lý nhất?

A. Bắt Exception chung, trả null để controller tự xử lý.
B. Bắt lỗi cụ thể, log có context, chuyển đổi sang exception nghiệp vụ phù hợp.
C. Nuốt hết exception để đảm bảo API luôn trả 200.
D. Chỉ dùng RuntimeException cho mọi lỗi.

### Câu 6 (Trung bình) - JDBC và SQL

Trong JDBC, để đảm bảo nhiều câu lệnh SQL cùng thành công hoặc cùng rollback, bạn cần dùng gì?

A. Batch update
B. Transaction (setAutoCommit false, commit/rollback)
C. Statement thay PreparedStatement
D. Connection pool

### Câu 7 (Trung bình - Khá) - REST API và HTTP

Endpoint cập nhật một phần thông tin hồ sơ khách hàng nên ưu tiên method nào?

A. GET
B. POST
C. PATCH
D. DELETE

### Câu 8 (Khá) - Spring Boot

Bạn muốn tiêm dependency theo constructor để dễ test và hạn chế null dependency. Cách làm phù hợp nhất là:

A. Dùng field injection với @Autowired trực tiếp trên biến.
B. Dùng constructor injection với constructor duy nhất của bean.
C. Tạo object bằng new trong controller.
D. Dùng static method để truy cập dependency toàn cục.

### Câu 9 (Khá - Nâng cao) - Multithreading

Hai thread cùng tăng biến đếm chung int counter bằng counter++ gây sai lệch kết quả. Nguyên nhân chính là:

A. JVM không hỗ trợ số nguyên.
B. counter++ không phải thao tác atomic.
C. int không lưu được giá trị lớn.
D. Garbage Collector dọn nhầm biến counter.

### Câu 10 (Nâng cao) - Tình huống thực tế

Bạn có class User dùng trong HashSet. equals/hashCode dựa trên trường email. Sau khi add vào set, code lại thay đổi email của object đó. Hậu quả dễ gặp nhất là gì?

A. HashSet tự cập nhật vị trí phần tử theo email mới.
B. Có thể không tìm thấy hoặc remove đúng phần tử đó dù nhìn có vẻ tồn tại.
C. Set sẽ ném exception ngay khi thay đổi email.
D. Không ảnh hưởng gì vì set chỉ quan tâm địa chỉ bộ nhớ object.

## 3) Gửi đáp án đề 2

Bạn gửi theo mẫu:

1A, 2B, 3C, 4D, 5A, 6B, 7C, 8D, 9A, 10B

Mình sẽ chấm theo đúng format trước đó:
- Điểm tổng
- Câu sai: gợi ý trước, rồi giải thích
- Phân tích điểm mạnh/yếu
- Danh sách ưu tiên ôn tiếp theo
