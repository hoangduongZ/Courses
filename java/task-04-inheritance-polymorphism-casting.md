# TASK 04 — Inheritance, Polymorphism, Casting

## Mục tiêu học tập
- Hiểu đúng kế thừa và cách constructor chain hoạt động.
- Nắm bản chất runtime polymorphism để thiết kế code mở rộng tốt.
- Phân biệt rõ overriding, overloading, static hiding.
- Tránh lỗi cast sai kiểu dẫn đến ClassCastException.

## 1) Bức tranh tổng quan
Task này trả lời 3 câu hỏi quan trọng trong OOP Java:
- Khi nào nên kế thừa, khi nào nên composition?
- Vì sao cùng một lời gọi method nhưng runtime cho kết quả khác nhau?
- Cast khi nào an toàn, khi nào nguy hiểm?

---

## 2) Inheritance fundamentals

## extends va quan hệ is-a
Kế thừa biểu diễn quan hệ is-a.

Ví dụ:
```java
class Employee {
	String name;
}

class Developer extends Employee {
	String primaryLanguage;
}
```

`Developer` la `Employee`, nên có thể dùng ở nơi cần Employee.

## super va constructor chain
- Constructor class con luôn gọi constructor class cha trước.
- Nếu không ghi rõ, Java tự chèn `super()` không tham số.

Ví dụ:
```java
class Employee {
	Employee(String name) {
		System.out.println("Employee ctor: " + name);
	}
}

class Developer extends Employee {
	Developer(String name) {
		super(name);
		System.out.println("Developer ctor");
	}
}
```

Luu y:
- Lời gọi `super(...)` phải là dòng đầu tiên trong constructor.

---

## 3) Polymorphism va overriding

## Runtime polymorphism
Biến kiểu cha có thể trỏ tới object kiểu con.

```java
class Employee {
	double monthlyPay() {
		return 0;
	}
}

class FullTimeEmployee extends Employee {
	@Override
	double monthlyPay() {
		return 3000;
	}
}

class Contractor extends Employee {
	@Override
	double monthlyPay() {
		return 2000;
	}
}

Employee e1 = new FullTimeEmployee();
Employee e2 = new Contractor();
System.out.println(e1.monthlyPay()); // 3000
System.out.println(e2.monthlyPay()); // 2000
```

Quyết định method nào chạy được chọn ở runtime theo object thực tế.

## Overriding rules cần nhớ
- Cùng tên, cùng parameter list.
- Return type có thể covariant (trả về subtype).
- Access modifier không được hẹp hơn cha.
- Không override method `final`, `static`, `private`.
- Nên dùng `@Override` để compiler bắt lỗi sớm.

---

## 4) Upcasting va downcasting

## Upcasting (an toàn)
```java
Developer dev = new Developer("An");
Employee emp = dev; // upcast, always safe
```

## Downcasting (cần kiểm tra)
```java
Employee emp = new Developer("An");
Developer dev = (Developer) emp; // safe vi object thuc la Developer
```

Sai tình huống:
```java
Employee emp = new Employee("Base");
Developer dev = (Developer) emp; // ClassCastException
```

## instanceof pattern matching (Java hien dai)
```java
if (emp instanceof Developer d) {
	System.out.println(d.primaryLanguage);
}
```

---

## 5) Static method hiding vs instance overriding

## Static method hiding
Static method thuộc class, không đa hình runtime như instance method.

```java
class Parent {
	static void info() { System.out.println("Parent"); }
}

class Child extends Parent {
	static void info() { System.out.println("Child"); }
}

Parent p = new Child();
p.info(); // Parent
```

## Instance method overriding
```java
class Parent {
	void info() { System.out.println("Parent"); }
}

class Child extends Parent {
	@Override
	void info() { System.out.println("Child"); }
}

Parent p = new Child();
p.info(); // Child
```

---

## 6) Interview focus (tra loi mau)

## Câu 1: Tại sao nên dùng kiểu cha cho biến tham chiếu?
Tra loi mau:
- Để tận dụng polymorphism, giảm coupling với implementation cụ thể.
- Code dễ mở rộng: thêm subtype mới mà không sửa nhiều chỗ gọi.
- Hỗ trợ dependency inversion và testability tốt hơn.

## Câu 2: Khi nào cast gây ClassCastException?
Tra loi mau:
- Khi downcast một reference mà object thực tế không phải subtype đó.
- Cast chỉ kiểm tra lúc runtime, nên compile pass nhưng runtime có thể fail.
- Dùng `instanceof` trước khi cast để an toàn.

---

## 7) Bài thực hành chính: Employee hierarchy

## Yêu cầu
- Tạo abstract class `Employee`:
  - Thuộc tính chung: `id`, `name`.
  - Method abstract: `double calculateSalary()`.
  - Method concrete: `String summary()`.
- Tạo 3 implementation:
  - `FullTimeEmployee` (fixed salary).
  - `PartTimeEmployee` (hourlyRate * hours).
  - `ContractEmployee` (contractAmount).
- Viết method tính tổng lương tháng của danh sách `List<Employee>`.

## Gợi ý code
```java
import java.util.List;

abstract class Employee {
	private final String id;
	private final String name;

	protected Employee(String id, String name) {
		this.id = id;
		this.name = name;
	}

	public abstract double calculateSalary();

	public String summary() {
		return id + " - " + name + " - " + calculateSalary();
	}
}

class FullTimeEmployee extends Employee {
	private final double monthlySalary;

	FullTimeEmployee(String id, String name, double monthlySalary) {
		super(id, name);
		this.monthlySalary = monthlySalary;
	}

	@Override
	public double calculateSalary() {
		return monthlySalary;
	}
}

class PartTimeEmployee extends Employee {
	private final double hourlyRate;
	private final int hours;

	PartTimeEmployee(String id, String name, double hourlyRate, int hours) {
		super(id, name);
		this.hourlyRate = hourlyRate;
		this.hours = hours;
	}

	@Override
	public double calculateSalary() {
		return hourlyRate * hours;
	}
}

class ContractEmployee extends Employee {
	private final double contractAmount;

	ContractEmployee(String id, String name, double contractAmount) {
		super(id, name);
		this.contractAmount = contractAmount;
	}

	@Override
	public double calculateSalary() {
		return contractAmount;
	}
}

class PayrollService {
	double totalPayroll(List<Employee> employees) {
		double total = 0;
		for (Employee e : employees) {
			total += e.calculateSalary();
		}
		return total;
	}
}
```

## Bài mở rộng
- Thêm `InternEmployee` mà không sửa `PayrollService`.
- Dùng `instanceof` pattern matching để xử lý rule riêng cho từng loại trong báo cáo.

---

## 8) Bài tập đoán output

1.
```java
class A {
	void m() { System.out.println("A"); }
}
class B extends A {
	@Override
	void m() { System.out.println("B"); }
}
A a = new B();
a.m();
```

2.
```java
class A {}
class B extends A {}
A a = new B();
System.out.println(a instanceof B);
```

3.
```java
class A {}
class B extends A {}
class C extends A {}
A a = new C();
B b = (B) a;
System.out.println(b);
```

4.
```java
class P {
	static void s() { System.out.println("P"); }
}
class C extends P {
	static void s() { System.out.println("C"); }
}
P p = new C();
p.s();
```

## Đáp án nhanh
1. `B`
2. `true`
3. Nem `ClassCastException`
4. `P`

---

## 9) Lỗi phổ biến cần tránh
- Lạm dụng inheritance dù quan hệ không phải is-a.
- Quên `@Override` dẫn đến viết sai signature.
- Downcast mà không check `instanceof`.
- Kỳ vọng static method chạy đa hình như instance method.

---

## 10) Checklist tự đánh giá
- Giải thích được constructor chain trong 1 phút.
- Trình bày được khác biệt overriding vs static hiding.
- Biết khi nào upcast/downcast và vì sao downcast rủi ro.
- Hoàn thành bài Employee hierarchy theo hướng mở rộng.
- Làm đúng >= 3/4 câu dự đoán output.
