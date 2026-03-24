# TASK 07 — Exceptions, Custom Exceptions, Try-with-resources

## Mục tiêu học tập
- Hiểu đúng cơ chế exception để xử lý lỗi có chủ đích.
- Phân biệt checked và unchecked và chọn đúng theo ngữ cảnh.
- Đóng resource an toàn bằng try-with-resources.
- Wrap exception mà vẫn giữ nguyên nhân gốc (`cause`).

## 1) Bức tranh tổng quan
Exception handling tốt không phải là "bắt hết lỗi".
Mục tiêu là:
- Bảo toàn ngữ cảnh để debug nhanh.
- Chia rõ trách nhiệm xử lý theo từng layer.
- Trả thông điệp lỗi phù hợp cho caller hoặc user.

---

## 2) Checked vs Unchecked exceptions

## Checked exception
- Kế thừa `Exception` (nhưng không kế thừa `RuntimeException`).
- Compiler ép phải catch hoặc khai báo `throws`.

Ví dụ:
```java
public String readFile(Path path) throws IOException {
	return Files.readString(path);
}
```

## Unchecked exception
- Kế thừa `RuntimeException`.
- Thường dùng cho programming errors hoặc business rule violations.

Ví dụ:
```java
public void deposit(long amount) {
	if (amount <= 0) {
		throw new IllegalArgumentException("amount must be > 0");
	}
}
```

Nguyên tắc thực dụng:
- Checked: lỗi bên ngoài hệ thống, có khả năng hồi phục (IO, network, parse file).
- Unchecked: lỗi logic/business sai đầu vào, không nên ép caller catch mọi nơi.

---

## 3) try-catch-finally và multi-catch

## try-catch-finally
```java
try {
	// code có thể ném exception
} catch (IOException e) {
	// xử lý riêng cho IOException
} finally {
	// chạy dù có exception hay không
}
```

## Multi-catch
Dùng khi logic xử lý giống nhau.

```java
try {
	Integer.parseInt(input);
} catch (NumberFormatException | NullPointerException e) {
	throw new IllegalArgumentException("invalid input", e);
}
```

Lưu ý:
- Không nên catch quá rộng nếu không có lý do rõ ràng.
- Catch theo mức độ cụ thể từ nhỏ đến lớn.

---

## 4) Try-with-resources và AutoCloseable

## Vì sao quan trọng
Tài nguyên như stream, file, socket cần được đóng đúng cách.
Try-with-resources tự động đóng resource, kể cả khi có exception.

Ví dụ:
```java
public List<String> readAllLines(Path path) throws IOException {
	try (BufferedReader br = Files.newBufferedReader(path)) {
		List<String> lines = new ArrayList<>();
		String line;
		while ((line = br.readLine()) != null) {
			lines.add(line);
		}
		return lines;
	}
}
```

## AutoCloseable
Object implement `AutoCloseable` có thể dùng trong try-with-resources.

```java
class AuditScope implements AutoCloseable {
	@Override
	public void close() {
		System.out.println("audit closed");
	}
}

try (AuditScope scope = new AuditScope()) {
	System.out.println("working");
}
```

---

## 5) Exception wrapping/chaining

## Mục tiêu
Không để lộ implementation details của lower layer,
nhưng vẫn giữ nguyên nhân gốc để debug.

Ví dụ:
```java
class FileParsingException extends RuntimeException {
	public FileParsingException(String message, Throwable cause) {
		super(message, cause);
	}
}

public List<Integer> loadNumbers(Path path) {
	try {
		return Files.lines(path)
			.map(String::trim)
			.filter(s -> !s.isEmpty())
			.map(Integer::parseInt)
			.toList();
	} catch (IOException | NumberFormatException e) {
		throw new FileParsingException("Failed to load numbers from: " + path, e);
	}
}
```

Lưu ý:
- Luôn truyền `cause` khi wrap exception.
- Thông điệp nên có context (file nào, operation nào, id nào).

---

## 6) Chiến lược xử lý exception theo layer

## Repository/Infra layer
- Bắt lỗi kỹ thuật cụ thể (IOException, SQLException).
- Wrap thành exception có ý nghĩa với domain/application.

## Service layer
- Validate business rules, ném custom business exception khi cần.
- Không bắt exception nếu không xử lý được.

## Controller/API layer
- Map exception thành HTTP status/response đúng nghĩa.
- Log một lần ở boundary để tránh trùng log.

---

## 7) Interview focus (trả lời mẫu)

## Câu 1: Khi nào tạo custom exception?
Trả lời mẫu:
- Tạo custom exception khi cần biểu đạt nghĩa lỗi theo domain/business,
  giúp caller xử lý theo semantic rõ ràng thay vì dựa vào exception chung chung.
- Ví dụ: `InsufficientBalanceException`, `PaymentDeclinedException`.

## Câu 2: Tại sao không nên bắt Exception quá rộng?
Trả lời mẫu:
- Dễ che giấu bug thật sự (vd NullPointerException) và làm mất stack trace quan trọng.
- Làm logic xử lý lỗi mơ hồ, khó debug, khó bảo trì.
- Nên bắt exception cụ thể và xử lý đúng ngữ cảnh.

---

## 8) Bài thực hành chính: Parse file service có logging + custom exception

## Yêu cầu
- Đọc file CSV đơn giản, mỗi dòng dạng `name,score`.
- Bỏ qua dòng rỗng.
- Nếu format sai, ném custom exception kèm line number.
- Log lỗi tại service layer trước khi throw.

## Gợi ý code
```java
import java.io.BufferedReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

record StudentScore(String name, int score) {}

class StudentFileParseException extends RuntimeException {
	public StudentFileParseException(String message, Throwable cause) {
		super(message, cause);
	}
}

class StudentFileService {
	private static final Logger LOG = Logger.getLogger(StudentFileService.class.getName());

	public List<StudentScore> parse(Path path) {
		List<StudentScore> result = new ArrayList<>();

		try (BufferedReader br = Files.newBufferedReader(path)) {
			String line;
			int lineNo = 0;

			while ((line = br.readLine()) != null) {
				lineNo++;
				String trimmed = line.trim();
				if (trimmed.isEmpty()) {
					continue;
				}

				String[] parts = trimmed.split(",");
				if (parts.length != 2) {
					throw new IllegalArgumentException("Invalid format at line " + lineNo);
				}

				String name = parts[0].trim();
				int score = Integer.parseInt(parts[1].trim());
				result.add(new StudentScore(name, score));
			}

			return result;
		} catch (IOException | NumberFormatException | IllegalArgumentException e) {
			LOG.log(Level.SEVERE, "Failed to parse file: " + path, e);
			throw new StudentFileParseException("Cannot parse file: " + path, e);
		}
	}
}
```

## Bài mở rộng
- Thêm validate score trong khoảng 0..100.
- Tách parse logic thành method riêng để unit test dễ hơn.

---

## 9) Bài tập đoán output

1.
```java
try {
	throw new IOException("io");
} catch (Exception e) {
	System.out.println(e.getClass().getSimpleName());
}
```

2.
```java
try {
	Integer.parseInt("x");
} catch (NumberFormatException e) {
	System.out.println("bad number");
} finally {
	System.out.println("finally");
}
```

3.
```java
try (java.io.ByteArrayInputStream in = new java.io.ByteArrayInputStream(new byte[]{1})) {
	System.out.println(in.read());
}
```

## Đáp án nhanh
1. `IOException`
2. `bad number` rồi `finally`
3. `1`

---

## 10) Lỗi phổ biến cần tránh
- Catch `Exception` ở quá nhiều tầng và nuốt lỗi.
- Throw exception mới nhưng không giữ `cause`.
- Log mọi tầng gây duplicate logs khó đọc.
- Không dùng try-with-resources cho IO resource.
- Dùng exception cho flow thông thường (control flow) không cần thiết.

---

## 11) Checklist tự đánh giá
- Phân biệt được checked vs unchecked bằng ví dụ cụ thể.
- Viết được custom exception có constructor `(message, cause)`.
- Dùng try-with-resources để đóng file an toàn.
- Wrap exception mà không mất context debug.
- Hoàn thành parse service và tự viết 3 test case lỗi.
