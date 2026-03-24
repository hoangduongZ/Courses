# TASK 13 — NIO.2, Files API, Serialization Pitfalls

## Mục tiêu học tập
- Dùng NIO.2 (`Path`, `Files`) để thao tác file hiện đại, rõ ràng và an toàn.
- Đọc/ghi file lớn đúng cách, tránh load toàn bộ vào memory.
- Hiểu nền tảng channel/buffer để trả lời interview và tối ưu IO.
- Nhận diện rủi ro Java native serialization và chọn giải pháp thay thế phù hợp.

## 1) Bức tranh tổng quan
IO là khu vực dễ gây:
- Chậm hiệu năng nếu đọc/ghi không tối ưu.
- OOM nếu đọc file lớn sai cách.
- Lỗ hổng bảo mật nếu dùng serialization thiếu kiểm soát.

Mục tiêu của task:
- Làm chủ NIO.2 cho bài toán file phổ biến.
- Biết khi nào cần stream/chunk thay vì đọc all-at-once.

---

## 2) Path, Paths, Files API

## Path
`Path` biểu diễn đường dẫn file/thư mục theo cách độc lập hệ điều hành.

```java
Path p = Path.of("data", "input.txt");
```

## Files API hay dùng
- `Files.exists(path)`
- `Files.createDirectories(path)`
- `Files.readString(path, charset)`
- `Files.writeString(path, content, charset)`
- `Files.newBufferedReader/newBufferedWriter`
- `Files.lines(path)`

Ví dụ:
```java
Path path = Path.of("logs", "app.log");
Files.createDirectories(path.getParent());
Files.writeString(path, "started\n", StandardCharsets.UTF_8,
	StandardOpenOption.CREATE, StandardOpenOption.APPEND);
```

Best practice:
- Luôn chỉ định charset (thường UTF-8).
- Dùng try-with-resources khi mở stream/reader/writer.

---

## 3) Buffered IO và charset

## Vì sao cần buffering
- Giảm số lần syscall IO.
- Tăng hiệu năng đáng kể khi đọc/ghi nhiều dòng.

Ví dụ đọc theo dòng:
```java
try (BufferedReader br = Files.newBufferedReader(path, StandardCharsets.UTF_8)) {
	String line;
	while ((line = br.readLine()) != null) {
		// process line
	}
}
```

Charset:
- Không chỉ định charset có thể gây lỗi ký tự khi deploy khác môi trường.

---

## 4) NIO channel/buffer fundamentals

## Khái niệm ngắn gọn
- Stream IO: luồng byte/char tuần tự.
- NIO: dùng `Channel` + `Buffer`, hỗ trợ thao tác linh hoạt hơn.

Ví dụ đọc file bằng `FileChannel` + `ByteBuffer`:
```java
try (FileChannel ch = FileChannel.open(path, StandardOpenOption.READ)) {
	ByteBuffer buf = ByteBuffer.allocate(8192);
	while (ch.read(buf) != -1) {
		buf.flip();
		// consume bytes in buf
		buf.clear();
	}
}
```

Điểm cần nhớ:
- `flip()` chuyển buffer từ mode ghi sang mode đọc.
- `clear()` chuẩn bị cho vòng đọc tiếp theo.

---

## 5) Java native serialization pitfalls

## Rủi ro chính
- Bảo mật: deserialization dữ liệu không tin cậy có thể bị khai thác.
- Khó tương thích phiên bản class theo thời gian.
- Dữ liệu nhị phân khó liên thông đa ngôn ngữ.

## serialVersionUID
- Giúp kiểm soát tương thích khi class thay đổi.
- Nếu mismatch có thể ném `InvalidClassException`.

Ví dụ:
```java
class User implements Serializable {
	private static final long serialVersionUID = 1L;
	String name;
}
```

## Khuyến nghị thực tế
- Tránh native serialization cho dữ liệu qua network/untrusted input.
- Ưu tiên JSON, Protobuf, Avro... tùy yêu cầu hiệu năng và schema evolution.

---

## 6) IO blocking cổ điển vs NIO

## Blocking IO cổ điển
- Thread thường chờ khi thao tác IO chưa xong.
- Dễ viết, phù hợp nhiều bài toán đơn giản.

## NIO
- Dùng channel/buffer, có thể mở rộng sang non-blocking selector model.
- Hữu ích cho workload nhiều kết nối hoặc IO hiệu năng cao.

Phỏng vấn thường cần trả lời:
- Không phải lúc nào NIO cũng nhanh hơn ngay lập tức.
- Chọn theo bài toán và độ phức tạp hệ thống.

---

## 7) Interview focus (trả lời mẫu)

## Câu 1: Vì sao nên cẩn thận với Java native serialization?
Trả lời mẫu:
- Native serialization có rủi ro bảo mật khi deserialize input không tin cậy.
- Tương thích phiên bản class khó quản lý, dễ lỗi khi model thay đổi.
- Độ liên thông kém giữa ngôn ngữ/hệ thống khác nhau.
- Vì vậy thường ưu tiên JSON/Protobuf và validation rõ ràng.

## Câu 2: Khác biệt IO blocking cổ điển và NIO?
Trả lời mẫu:
- IO blocking truyền thống đơn giản, thread có thể bị chặn khi chờ IO.
- NIO dùng channel/buffer và có mô hình non-blocking, phù hợp hệ thống cần xử lý nhiều IO đồng thời.
- Đổi lại NIO thường phức tạp hơn, cần cân nhắc chi phí kỹ thuật.

---

## 8) Bài thực hành chính: Utility đọc file lớn theo stream

## Yêu cầu
- Viết utility đếm số dòng và số ký tự của file lớn.
- Không đọc toàn bộ file vào memory.
- Cho phép truyền `Charset`.
- Dùng try-with-resources.

## Gợi ý code
```java
import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

record FileStats(long lines, long chars) {}

class LargeFileUtil {
	public static FileStats analyze(Path path, Charset charset) throws IOException {
		if (path == null) {
			throw new IllegalArgumentException("path is required");
		}
		Charset cs = (charset == null) ? StandardCharsets.UTF_8 : charset;

		long lineCount = 0;
		long charCount = 0;

		try (BufferedReader br = Files.newBufferedReader(path, cs)) {
			String line;
			while ((line = br.readLine()) != null) {
				lineCount++;
				charCount += line.length();
			}
		}

		return new FileStats(lineCount, charCount);
	}
}
```

## Bài mở rộng
- Viết thêm method đọc theo chunk bytes bằng `FileChannel`.
- Thêm callback xử lý từng dòng (`Consumer<String>`) để pipeline linh hoạt hơn.

---

## 9) Bài tập đoán output/hành vi

1.
```java
Path p = Path.of("a", "b", "c.txt");
System.out.println(p.getNameCount());
```

2.
```java
List<String> lines = Files.readAllLines(path, StandardCharsets.UTF_8);
System.out.println(lines.size());
```

3.
```java
try (Stream<String> s = Files.lines(path)) {
	System.out.println(s.count());
}
```

## Đáp án nhanh
1. `3`
2. In số dòng, nhưng cách này có thể tốn nhiều memory với file lớn.
3. In số dòng và không rò rỉ resource vì đã đóng stream đúng cách.

---

## 10) Lỗi phổ biến cần tránh
- Dùng `readAllBytes/readAllLines` cho file rất lớn.
- Không chỉ định charset khi đọc/ghi text.
- Quên đóng stream/channel gây leak resource.
- Dùng Java native deserialization cho input không tin cậy.
- Dựa vào `available()` để suy luận đầy đủ kích thước stream.

---

## 11) Checklist tự đánh giá
- Dùng thành thạo `Path` và `Files` cho tác vụ file phổ biến.
- Phân biệt được khi nào đọc all-at-once, khi nào stream/chunk.
- Giải thích được vai trò của channel/buffer.
- Nêu được rủi ro chính của native serialization.
- Hoàn thành utility đọc file lớn và tự viết test với file vài trăm MB.
