# TASK 01 — Java Basics, Data Types, Operators

## Mục tiêu học tập
- Nắm chắc primitive và reference type trong Java.
- Hiểu promotion/casting để tránh bug số học.
- Dùng toán tử đúng thứ tự ưu tiên, hiểu short-circuit.
- Phân biệt `==` và `equals()` trong các tình huống phỏng vấn.

## 1) Bức tranh tổng quan
Java chia kiểu dữ liệu thành 2 nhóm lớn:
- Primitive types: lưu trực tiếp giá trị.
- Reference types: lưu địa chỉ object.

Khi tính toán số học, Java thường "nâng kiểu" (promotion) để an toàn.
Việc so sánh object cần rõ: so sánh địa chỉ hay so sánh nội dung.

---

## 2) Primitive vs Reference

## Primitive types
- `byte` (8-bit), `short` (16-bit), `int` (32-bit), `long` (64-bit)
- `float` (32-bit), `double` (64-bit)
- `char` (16-bit, Unicode)
- `boolean` (`true`/`false`)

Ví dụ:
```java
int age = 25;
double score = 8.5;
char grade = 'A';
boolean active = true;
```

## Reference types
- Ví dụ: `String`, `Array`, class tự định nghĩa.
- Biến lưu reference, không phải bản thân object.

Ví dụ:
```java
String name = "Hoang";
int[] nums = {1, 2, 3};
```

## Default values (quan trọng cho OCP)
- Field của class có default value.
- Local variable trong method: KHONG có default, phải khởi tạo trước khi dùng.

Ví dụ:
```java
class User {
	int age;        // default 0
	boolean active; // default false
}
```

---

## 3) Wrapper classes và autoboxing
- Primitive tương ứng wrapper: `int` <-> `Integer`, `double` <-> `Double`.
- Java hỗ trợ autoboxing/unboxing tự động.

Ví dụ:
```java
Integer a = 10; // autoboxing
int b = a;      // unboxing
```

Luu y:
- `Integer` có thể là `null`, `int` thì không.
- Unboxing `null` sẽ ném `NullPointerException`.

---

## 4) Numeric promotion, casting, overflow

## Promotion rules cơ bản
- Trong biểu thức số học, `byte`, `short`, `char` duoc promote len `int`.
- Nếu có `double` thì kết quả thường lên `double`.
- Nếu có `float` và không có `double` thì lên `float`.

Ví dụ:
```java
byte x = 10;
byte y = 20;
int z = x + y; // dung, vi x+y la int
```

## Widening vs narrowing
- Widening (an toàn): `int -> long -> float -> double`.
- Narrowing (mất dữ liệu có thể xảy ra): cần cast tường minh.

Ví dụ:
```java
int i = 130;
byte b = (byte) i; // b = -126 (mat du lieu)
```

## Overflow/underflow
Java không báo lỗi khi tràn số nguyên, giá trị quay vòng theo 2's complement.

Ví dụ:
```java
int max = Integer.MAX_VALUE;
System.out.println(max + 1); // -2147483648
```

---

## 5) Operators và precedence

## Nhóm toán tử hay gặp
- Arithmetic: `+ - * / %`
- Unary: `++ -- + - !`
- Relational: `== != > < >= <=`
- Logical: `&& || !`
- Assignment: `= += -= *= /= %=`
- Ternary: `condition ? a : b`

## Precedence cần nhớ nhanh
- Unary > Multiplicative > Additive > Relational > Equality > Logical AND > Logical OR > Ternary > Assignment
- Khi nghi ngờ, thêm ngoặc `()` để code rõ ràng.

Ví dụ:
```java
int a = 2 + 3 * 4;      // 14
int b = (2 + 3) * 4;    // 20
```

## Short-circuit (`&&`, `||`)
- `A && B`: nếu `A` false, `B` KHONG chạy.
- `A || B`: nếu `A` true, `B` KHONG chạy.

Ví dụ:
```java
int n = 0;
if (n != 0 && 10 / n > 1) {
	System.out.println("ok");
}
// Khong bi ArithmeticException do ve trai da false
```

---

## 6) `==` vs `equals()`

## Primitive
- `==` so sánh giá trị.

## Reference
- `==` so sánh địa chỉ (cùng object hay không).
- `equals()` so sánh nội dung (neu class override hợp lý).

Ví dụ với String:
```java
String s1 = "java";
String s2 = "java";
String s3 = new String("java");

System.out.println(s1 == s2);      // true (string pool)
System.out.println(s1 == s3);      // false (khac object)
System.out.println(s1.equals(s3)); // true (cung noi dung)
```

Best practice:
```java
if ("ACTIVE".equals(status)) {
	// tranh NullPointerException neu status == null
}
```

---

## 7) Interview focus (tra loi mau ngan gon)

## Câu 1: "Vì sao `byte + byte` ra `int`?"
Tra loi mau:
- Trong Java, các toán hạng `byte`, `short`, `char` được numeric promotion lên `int` trước khi tính.
- Vì vậy `x + y` có kiểu `int`, muốn gán lại `byte` cần cast tường minh.

## Câu 2: "`==` khác `equals()` thế nào?"
Tra loi mau:
- Với primitive, `==` so sánh giá trị.
- Với reference, `==` so sánh cùng object hay không.
- `equals()` so sánh nội dung logic của object (tùy class override).

---

## 8) Bài tập dự đoán output (10 câu)

1.
```java
byte a = 100;
byte b = 27;
int c = a + b;
System.out.println(c);
```

2.
```java
int x = 5;
System.out.println(x++ + ++x);
```

3.
```java
int max = Integer.MAX_VALUE;
System.out.println(max + 1);
```

4.
```java
double d = 10 / 4;
System.out.println(d);
```

5.
```java
double d = 10 / 4.0;
System.out.println(d);
```

6.
```java
String s1 = "ocp";
String s2 = "ocp";
System.out.println(s1 == s2);
```

7.
```java
String s1 = new String("ocp");
String s2 = new String("ocp");
System.out.println(s1 == s2);
System.out.println(s1.equals(s2));
```

8.
```java
int n = 0;
System.out.println(n != 0 && 10 / n > 1);
```

9.
```java
char ch = 'A';
System.out.println(ch + 1);
```

10.
```java
int i = 130;
byte b = (byte) i;
System.out.println(b);
```

## Đáp án nhanh
1. `127`
2. `12`
3. `-2147483648`
4. `2.0`
5. `2.5`
6. `true`
7. `false` va `true`
8. `false`
9. `66`
10. `-126`

---

## 9) Checklist tự đánh giá
- Giải thích được promotion mà không nhìn tài liệu.
- Phân biệt rõ `==` và `equals()` trong 30 giây.
- Nhìn biểu thức biết nơi có thể overflow/casting lỗi.
- Làm đúng >= 8/10 bài dự đoán output.
