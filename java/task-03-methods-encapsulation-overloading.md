# TASK 03 — Methods, Encapsulation, Overloading

## Mục tiêu học tập
- Thiết kế method rõ nghĩa, dễ đọc, dễ test.
- Hiểu đúng pass-by-value trong Java để tránh hiểu sai reference.
- Áp dụng encapsulation để bảo vệ trạng thái object.
- Dùng overloading hợp lý, không tạo API mơ hồ.

## 1) Bức tranh tổng quan
Task này trả lời câu hỏi cốt lõi khi thiết kế class:
- Method nào nên public, method nào nên private?
- Dữ liệu nội bộ có nên cho sửa trực tiếp không?
- Overload bao nhiêu là đủ để API tiện nhưng không rối?

---

## 2) Method fundamentals

## Method signature
Trong Java, method signature gồm:
- Tên method.
- Danh sách kiểu tham số theo thứ tự.

Luu y:
- Return type KHONG thuộc signature.

Ví dụ:
```java
void print(int x) {}
void print(String x) {}
// hop le: khac signature

// int print(int x) {}
// void print(int x) {}
// khong hop le: cung signature, chi khac return type
```

## Return type va design
- Trả về giá trị mới nếu method có tính "tính toán".
- Dùng void cho hành động side-effect rõ ràng.

Ví dụ:
```java
int sum(int a, int b) {
	return a + b;
}

void log(String message) {
	System.out.println(message);
}
```

## Varargs
Varargs cho phép truyền số lượng tham số linh hoạt.

Ví dụ:
```java
int total(int... values) {
	int sum = 0;
	for (int v : values) {
		sum += v;
	}
	return sum;
}
```

Luu y:
- Mỗi method chỉ có tối đa 1 varargs.
- Varargs phải ở tham số cuối cùng.

---

## 3) Pass-by-value trong Java
Java luôn pass-by-value.

## Primitive case
```java
void change(int x) {
	x = 100;
}

int a = 10;
change(a);
System.out.println(a); // 10
```

## Reference case
Java truyền bản sao của reference.

```java
class User {
	String name;
	User(String name) { this.name = name; }
}

void rename(User u) {
	u.name = "B"; // doi state object that reference points to
}

void reassign(User u) {
	u = new User("C"); // chi doi bien local u
}

User user = new User("A");
rename(user);
System.out.println(user.name); // B
reassign(user);
System.out.println(user.name); // van la B
```

Ket luan:
- Primitive: không đổi được biến gốc.
- Reference: có thể đổi nội dung object, nhưng không đổi reference gốc ở caller.

---

## 4) Encapsulation

## Nguyên tắc
- Field để private.
- Public methods để kiểm soát trạng thái.
- Không để object vào trạng thái invalid.

Ví dụ tốt:
```java
class BankAccount {
	private long balance;

	public long getBalance() {
		return balance;
	}

	public void deposit(long amount) {
		if (amount <= 0) {
			throw new IllegalArgumentException("amount must be > 0");
		}
		balance += amount;
	}
}
```

Loi thiet ke pho bien:
- Expose field public để sửa trực tiếp.
- Getter trả object mutable mà không defensive copy.

---

## 5) Overloading

## Overloading la gi
Cùng tên method, khác danh sách tham số.
Binding diễn ra lúc compile-time.

Ví dụ:
```java
class Printer {
	void print(int x) { System.out.println("int: " + x); }
	void print(String s) { System.out.println("str: " + s); }
	void print(Object o) { System.out.println("obj: " + o); }
}
```

## Rule chọn overload (đơn giản hóa để nhớ)
- Match exact type ưu tiên cao.
- Sau đó đến widening.
- Sau đó boxing/unboxing.
- Sau đó varargs.

## Ambiguous overload can happen
```java
void f(Integer x) {}
void f(Long x) {}

// f(null); // compile error: ambiguous
```

Best practice:
- Không overload quá nhiều nếu behavior khác biệt lớn.
- Nếu dễ mơ hồ, đổi tên method để rõ ý nghĩa.

---

## 6) Interview focus (tra loi mau)

## Câu 1: Java có pass-by-reference không?
Tra loi mau:
- Không. Java luôn pass-by-value.
- Với object, giá trị được truyền là bản sao của reference.
- Do đó có thể sửa state object, nhưng không thể đổi reference gốc ở caller.

## Câu 2: Overloading khác overriding ở thời điểm nào?
Tra loi mau:
- Overloading: quyết định lúc compile-time dựa trên kiểu tham số.
- Overriding: quyết định lúc runtime dựa trên object thực tế (dynamic dispatch).

---

## 7) Bài thực hành chính: Money class

## Yêu cầu
- `Money` immutable.
- Không chấp nhận amount âm.
- Currency không được null/blank.
- Có method `add(Money other)`:
  - Cùng currency mới được cộng.
  - Khác currency thì ném exception.
- Override `equals`, `hashCode`, `toString`.

## Gợi ý thiết kế
```java
import java.math.BigDecimal;
import java.util.Objects;

public final class Money {
	private final BigDecimal amount;
	private final String currency;

	public Money(BigDecimal amount, String currency) {
		if (amount == null || amount.signum() < 0) {
			throw new IllegalArgumentException("amount must be >= 0");
		}
		if (currency == null || currency.isBlank()) {
			throw new IllegalArgumentException("currency is required");
		}
		this.amount = amount;
		this.currency = currency;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public String getCurrency() {
		return currency;
	}

	public Money add(Money other) {
		Objects.requireNonNull(other, "other must not be null");
		if (!this.currency.equals(other.currency)) {
			throw new IllegalArgumentException("currency mismatch");
		}
		return new Money(this.amount.add(other.amount), this.currency);
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (!(o instanceof Money)) return false;
		Money money = (Money) o;
		return amount.compareTo(money.amount) == 0 && currency.equals(money.currency);
	}

	@Override
	public int hashCode() {
		return Objects.hash(amount.stripTrailingZeros(), currency);
	}

	@Override
	public String toString() {
		return amount + " " + currency;
	}
}
```

## Bài mở rộng
- Thêm factory methods overload:
  - `of(long amount, String currency)`
  - `of(String amount, String currency)`
- Thảo luận: overload như vậy có rõ ràng hay nên dùng tên khác?

---

## 8) Bài tập đoán output

1.
```java
void m(int x) { System.out.println("int"); }
void m(long x) { System.out.println("long"); }
m(10);
```

2.
```java
void m(Integer x) { System.out.println("Integer"); }
void m(int... x) { System.out.println("varargs"); }
m(5);
```

3.
```java
class A {
	int v = 1;
}
void change(A a) { a.v = 9; }
A a = new A();
change(a);
System.out.println(a.v);
```

4.
```java
class A {
	int v = 1;
}
void reassign(A a) { a = new A(); a.v = 9; }
A a = new A();
reassign(a);
System.out.println(a.v);
```

## Đáp án nhanh
1. `int`
2. `Integer`
3. `9`
4. `1`

---

## 9) Checklist tự đánh giá
- Giải thích được method signature trong 30 giây.
- Trả lời đúng pass-by-value với ví dụ primitive và reference.
- Thiết kế class có invariant bằng encapsulation.
- Dùng overloading không gây ambiguous.
- Hoàn thành Money class và tự viết test case cơ bản.
