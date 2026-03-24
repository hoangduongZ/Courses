# TASK 05 — Abstract Class, Interface, Sealed, Records

## Mục tiêu học tập
- Chọn đúng công cụ thiết kế giữa abstract class, interface, sealed, record.
- Hiểu trade-off để trả lời câu hỏi thiết kế ở level Junior -> Middle.
- Áp dụng vào mô hình kết quả nghiệp vụ (PaymentResult) rõ ràng, an toàn.

## 1) Bức tranh tổng quan
Trong Java hiện đại, 4 công cụ này giải quyết 4 nhu cầu khác nhau:
- Abstract class: chia sẻ state + logic chung trong cùng một họ class.
- Interface: định nghĩa contract linh hoạt cho nhiều implementation.
- Sealed: kiểm soát tập subtype hợp lệ (closed hierarchy).
- Record: mô hình dữ liệu bất biến, gọn, ít boilerplate.

---

## 2) Abstract class

## Khi nên dùng
- Nhiều class con cùng chia sẻ state và behavior mặc định.
- Muốn ép class con override một số method bắt buộc.

Ví dụ:
```java
abstract class NotificationSender {
	protected final String systemName;

	protected NotificationSender(String systemName) {
		this.systemName = systemName;
	}

	public void sendWithAudit(String receiver, String content) {
		validate(receiver, content);
		doSend(receiver, content);
		System.out.println("audit from " + systemName);
	}

	protected void validate(String receiver, String content) {
		if (receiver == null || receiver.isBlank()) {
			throw new IllegalArgumentException("receiver required");
		}
		if (content == null || content.isBlank()) {
			throw new IllegalArgumentException("content required");
		}
	}

	protected abstract void doSend(String receiver, String content);
}
```

## Điểm mạnh
- Tái sử dụng code tốt khi có logic chung rõ ràng.

## Hạn chế
- Java chỉ cho single inheritance (một class chỉ extends một class cha).

---

## 3) Interface

## Khi nên dùng
- Cần contract chung cho nhiều implementation khác nhau.
- Muốn linh hoạt thay thế implementation (DIP, test, mocking).

Ví dụ:
```java
interface PaymentGateway {
	PaymentResult pay(String orderId, long amount);

	default boolean supportsCurrency(String currency) {
		return "VND".equals(currency) || "USD".equals(currency);
	}

	static void validateAmount(long amount) {
		if (amount <= 0) {
			throw new IllegalArgumentException("amount must be > 0");
		}
	}
}
```

## Điểm mạnh
- Một class có thể implement nhiều interface.
- Rất phù hợp để định nghĩa API/service contracts.

## Hạn chế
- Không có instance state chung như abstract class.

---

## 4) Sealed class/interface

## Mục đích
Giới hạn các subtype hợp lệ để mô hình domain chặt chẽ hơn.

Ví dụ:
```java
public sealed interface PaymentResult
		permits PaymentSuccess, PaymentDeclined, PaymentError {
}

record PaymentSuccess(String transactionId) implements PaymentResult {}
record PaymentDeclined(String reason) implements PaymentResult {}
record PaymentError(String errorCode, String message) implements PaymentResult {}
```

Lợi ích:
- Tránh implementation "ngoài ý muốn".
- Dễ kiểm soát logic xử lý theo từng trường hợp.
- Đọc code domain rõ ràng hơn.

Luu y:
- Các subtype được phép phải là `final`, `sealed` hoặc `non-sealed`.

---

## 5) Record

## Khi nên dùng
- Class chỉ mang dữ liệu, immutable-by-design.
- Cần `equals/hashCode/toString` tự sinh gọn gàng.

Ví dụ:
```java
public record Money(long amount, String currency) {
	public Money {
		if (amount < 0) throw new IllegalArgumentException("amount must be >= 0");
		if (currency == null || currency.isBlank()) throw new IllegalArgumentException("currency required");
	}
}
```

Luu y:
- Record không phù hợp khi object có state biến đổi phức tạp hoặc lifecycle đặc biệt.

---

## 6) Decision guide (chọn công cụ nhanh)

## Dùng abstract class khi
- Cần state chung + shared logic + template behavior.

## Dùng interface khi
- Cần contract linh hoạt và nhiều implementation độc lập.

## Dùng sealed khi
- Muốn giới hạn số subtype hợp lệ cho domain model.

## Dùng record khi
- Chỉ cần data carrier bất biến, nhẹ, rõ ràng.

---

## 7) Interview focus (tra loi mau)

## Câu 1: So sánh interface và abstract class trong thiết kế API
Tra loi mau:
- Interface phù hợp để định nghĩa contract và tách phụ thuộc, class có thể implement nhiều interface.
- Abstract class phù hợp khi cần chia sẻ state và behavior mặc định giữa các class cùng họ.
- Nếu chỉ cần "khả năng" (capability), ưu tiên interface; nếu cần nền tảng dùng chung có trạng thái, cân nhắc abstract class.

## Câu 2: Khi nào record phù hợp hơn class thường?
Tra loi mau:
- Khi object chủ yếu mang dữ liệu bất biến và không cần nhiều hành vi phức tạp.
- Record giúp giảm boilerplate (constructor, equals, hashCode, toString) và biểu đạt ý đồ data model rõ hơn.

---

## 8) Bài thực hành chính: PaymentResult sealed hierarchy

## Yêu cầu
- Thiết kế sealed hierarchy cho kết quả thanh toán gồm:
  - Thành công.
  - Từ chối bởi nghiệp vụ.
  - Lỗi hệ thống.
- Viết hàm format message theo từng loại kết quả.
- Không dùng string status rời rạc kiểu "SUCCESS/FAILED".

## Gợi ý code
```java
public sealed interface PaymentResult
		permits PaymentSuccess, PaymentDeclined, PaymentError {
}

public record PaymentSuccess(String transactionId, long amount) implements PaymentResult {
	public PaymentSuccess {
		if (transactionId == null || transactionId.isBlank()) {
			throw new IllegalArgumentException("transactionId required");
		}
		if (amount <= 0) {
			throw new IllegalArgumentException("amount must be > 0");
		}
	}
}

public record PaymentDeclined(String reason) implements PaymentResult {
	public PaymentDeclined {
		if (reason == null || reason.isBlank()) {
			throw new IllegalArgumentException("reason required");
		}
	}
}

public record PaymentError(String errorCode, String message) implements PaymentResult {
	public PaymentError {
		if (errorCode == null || errorCode.isBlank()) {
			throw new IllegalArgumentException("errorCode required");
		}
		if (message == null || message.isBlank()) {
			throw new IllegalArgumentException("message required");
		}
	}
}

class PaymentResultFormatter {
	String toMessage(PaymentResult result) {
		if (result instanceof PaymentSuccess s) {
			return "SUCCESS tx=" + s.transactionId() + ", amount=" + s.amount();
		}
		if (result instanceof PaymentDeclined d) {
			return "DECLINED reason=" + d.reason();
		}
		if (result instanceof PaymentError e) {
			return "ERROR code=" + e.errorCode() + ", message=" + e.message();
		}
		throw new IllegalStateException("Unknown result type: " + result);
	}
}
```

## Bài mở rộng
- Tạo interface `PaymentGateway` và 2 implementation giả lập `MomoGateway`, `VnPayGateway`.
- Tất cả gateway trả về `PaymentResult` sealed hierarchy.

---

## 9) Bài tập đoán output

1.
```java
interface A {
	default String name() { return "A"; }
}
class B implements A {}
System.out.println(new B().name());
```

2.
```java
abstract class A {
	abstract int x();
}
class B extends A {
	@Override int x() { return 10; }
}
A a = new B();
System.out.println(a.x());
```

3.
```java
record User(String name) {}
User u1 = new User("An");
User u2 = new User("An");
System.out.println(u1.equals(u2));
```

## Đáp án nhanh
1. `A`
2. `10`
3. `true`

---

## 10) Lỗi phổ biến cần tránh
- Dùng abstract class chỉ để định nghĩa contract thuần túy.
- Dùng record cho object cần mutable state phức tạp.
- Dùng String status rời rạc thay vì sealed hierarchy cho domain kết quả hữu hạn.
- Tạo interface quá nhiều method không liên quan (vi phạm ISP).

---

## 11) Checklist tự đánh giá
- Giải thích được khi nào chọn abstract class, interface, sealed, record.
- Thiết kế được `PaymentResult` sealed hierarchy không dùng status string.
- Trả lời được 2 câu interview focus trong 2-3 phút.
- Hoàn thành bài thực hành và tự viết test cơ bản cho từng subtype.
