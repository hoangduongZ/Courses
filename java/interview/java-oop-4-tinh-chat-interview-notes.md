# Java OOP – Kiến thức phỏng vấn về 4 tính chất

## 1) 4 tính chất là gì

Trong Java, 4 tính chất lập trình hướng đối tượng thường được hỏi là:

- **Encapsulation** — Đóng gói
- **Inheritance** — Kế thừa
- **Polymorphism** — Đa hình
- **Abstraction** — Trừu tượng

Đây là bộ nền tảng cực hay bị hỏi ở phỏng vấn fresher, junior, mid, thậm chí senior nếu muốn kiểm tra tư duy cơ bản.

---

## 2) Encapsulation — Đóng gói

### Định nghĩa
Đóng gói là việc **ẩn dữ liệu bên trong object** và chỉ cho phép truy cập thông qua các method phù hợp.

Nói dễ hiểu:
- không cho bên ngoài đụng trực tiếp vào dữ liệu nhạy cảm
- bắt buộc đi qua một lớp kiểm soát

### Ví dụ
```java
class BankAccount {
    private double balance;

    public void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
        }
    }

    public double getBalance() {
        return balance;
    }
}
```

### Ý nghĩa
- `balance` là `private`
- bên ngoài không thể sửa bừa:
```java
// account.balance = -1000; // lỗi
```
- muốn thay đổi phải qua `deposit()`

### Lợi ích
- bảo vệ dữ liệu
- tránh object rơi vào trạng thái sai
- dễ kiểm soát logic nghiệp vụ
- dễ bảo trì hơn

### Câu trả lời phỏng vấn ngắn
> Encapsulation là đóng gói dữ liệu và hành vi trong cùng một class, đồng thời giới hạn truy cập trực tiếp vào dữ liệu bằng access modifier như `private`, rồi cung cấp quyền truy cập có kiểm soát qua method.

### Điểm dễ nhầm
Encapsulation **không chỉ là viết getter/setter**.

Ví dụ này chưa phải encapsulation tốt:
```java
class User {
    public String name;
}
```

Hoặc:
```java
class User {
    private int age;

    public void setAge(int age) {
        this.age = age;
    }
}
```

Nếu setter không validate gì cả thì chỉ mới che field, chưa tận dụng tốt encapsulation.

Tốt hơn:
```java
class User {
    private int age;

    public void setAge(int age) {
        if (age < 0) {
            throw new IllegalArgumentException("age must be >= 0");
        }
        this.age = age;
    }
}
```

---

## 3) Inheritance — Kế thừa

### Định nghĩa
Kế thừa là việc class con **nhận lại thuộc tính và hành vi** từ class cha.

### Ví dụ
```java
class Animal {
    public void eat() {
        System.out.println("Animal is eating");
    }
}

class Dog extends Animal {
    public void bark() {
        System.out.println("Dog is barking");
    }
}
```

### Dùng
```java
Dog d = new Dog();
d.eat();
d.bark();
```

### Ý nghĩa
- `Dog` kế thừa `Animal`
- `Dog` có thể dùng lại `eat()`
- đồng thời có thêm `bark()`

### Lợi ích
- tái sử dụng code
- giảm lặp code
- mô hình hóa quan hệ cha-con

### Câu trả lời phỏng vấn ngắn
> Inheritance là cơ chế cho phép class con kế thừa thuộc tính và phương thức từ class cha thông qua `extends`, giúp tái sử dụng code và mở rộng hành vi.

### Điểm quan trọng trong Java
Java:
- hỗ trợ **single inheritance** với class
- không cho một class `extends` nhiều class
- nhưng cho một class `implements` nhiều interface

Ví dụ:
```java
class A {}
// class B extends A, C {} // sai

interface X {}
interface Y {}
class B implements X, Y {}
```

### Điểm dễ nhầm
Không phải lúc nào cũng nên dùng inheritance.

Ví dụ:
- `Car extends Engine` là sai về quan hệ
- đúng hơn là `Car has an Engine`

Đây là phân biệt:
- **is-a** → hay dùng inheritance
- **has-a** → hay dùng composition

Ví dụ:
- `Dog is an Animal` → hợp lý để kế thừa
- `Car has an Engine` → nên composition

---

## 4) Polymorphism — Đa hình

### Định nghĩa
Đa hình là khả năng **cùng một lời gọi method nhưng hành vi khác nhau tùy object thực tế**.

Nói dễ hiểu:
- cùng tên method
- nhưng object khác nhau thì chạy khác nhau

### Ví dụ override
```java
class Animal {
    public void sound() {
        System.out.println("Animal sound");
    }
}

class Dog extends Animal {
    @Override
    public void sound() {
        System.out.println("Dog barks");
    }
}

class Cat extends Animal {
    @Override
    public void sound() {
        System.out.println("Cat meows");
    }
}
```

### Dùng
```java
Animal a1 = new Dog();
Animal a2 = new Cat();

a1.sound(); // Dog barks
a2.sound(); // Cat meows
```

### Ý nghĩa
Biến đều là kiểu `Animal`, nhưng method chạy theo object thực tế:
- `Dog`
- `Cat`

Đây là **runtime polymorphism**.

### Lợi ích
- code linh hoạt
- dễ mở rộng
- lập trình theo abstraction tốt hơn

### Câu trả lời phỏng vấn ngắn
> Polymorphism là khả năng một interface hoặc kiểu cha có thể tham chiếu đến nhiều object con khác nhau, và cùng một method call có thể thực thi hành vi khác nhau tùy object thực tế.

### 2 loại đa hình thường được nhắc

#### Runtime polymorphism
Thông qua **method overriding**

Ví dụ:
```java
Animal a = new Dog();
a.sound();
```

#### Compile-time polymorphism
Thông qua **method overloading**

Ví dụ:
```java
class Calculator {
    int add(int a, int b) {
        return a + b;
    }

    double add(double a, double b) {
        return a + b;
    }
}
```

Phỏng vấn nhiều nơi khi nói “đa hình” sẽ ưu tiên hỏi **overriding** hơn.

### Overloading vs Overriding

#### Overloading
- cùng tên method
- khác parameter list
- xảy ra lúc compile time

#### Overriding
- class con viết lại method của cha
- cùng signature
- xảy ra runtime

---

## 5) Abstraction — Trừu tượng

### Định nghĩa
Trừu tượng là việc **chỉ thể hiện những gì cần thiết**, còn chi tiết bên trong thì ẩn đi.

Nói dễ hiểu:
- người dùng biết **dùng như thế nào**
- không cần biết **bên trong làm ra sao**

### Ví dụ với abstract class
```java
abstract class Shape {
    abstract double area();
}
```

```java
class Circle extends Shape {
    private double radius;

    Circle(double radius) {
        this.radius = radius;
    }

    @Override
    double area() {
        return Math.PI * radius * radius;
    }
}
```

### Ví dụ với interface
```java
interface PaymentService {
    void pay(double amount);
}
```

```java
class CreditCardPayment implements PaymentService {
    @Override
    public void pay(double amount) {
        System.out.println("Pay by credit card: " + amount);
    }
}
```

### Ý nghĩa
Code gọi chỉ cần biết:
```java
PaymentService service = new CreditCardPayment();
service.pay(100);
```

Không cần biết:
- gọi API gì
- lưu log ra sao
- xác thực kiểu gì

### Lợi ích
- giảm phụ thuộc vào implementation cụ thể
- code dễ thay đổi
- dễ test
- dễ mở rộng

### Câu trả lời phỏng vấn ngắn
> Abstraction là việc ẩn chi tiết cài đặt và chỉ lộ ra những hành vi cần thiết thông qua abstract class hoặc interface.

---

## 6) Phân biệt Encapsulation và Abstraction

Đây là câu cực hay hỏi.

### Encapsulation
Tập trung vào:
- **ẩn dữ liệu**
- **bảo vệ trạng thái object**
- kiểm soát truy cập

Ví dụ:
- field `private`
- validate qua setter hoặc method

### Abstraction
Tập trung vào:
- **ẩn chi tiết cài đặt**
- chỉ cho người dùng biết cách sử dụng

Ví dụ:
- interface `PaymentService`
- abstract class `Shape`

### Câu trả lời dễ nhớ
> Encapsulation là giấu dữ liệu và kiểm soát truy cập vào dữ liệu. Abstraction là giấu cách cài đặt và chỉ lộ ra hành vi cần thiết.

---

## 7) Ví dụ tổng hợp cả 4 tính chất

```java
abstract class Animal {
    private String name; // Encapsulation

    public Animal(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public abstract void sound(); // Abstraction
}
```

```java
class Dog extends Animal { // Inheritance
    public Dog(String name) {
        super(name);
    }

    @Override
    public void sound() { // Polymorphism qua overriding
        System.out.println(getName() + " barks");
    }
}
```

```java
class Cat extends Animal {
    public Cat(String name) {
        super(name);
    }

    @Override
    public void sound() {
        System.out.println(getName() + " meows");
    }
}
```

```java
public class Main {
    public static void main(String[] args) {
        Animal a1 = new Dog("Milo");
        Animal a2 = new Cat("Luna");

        a1.sound();
        a2.sound();
    }
}
```

### Phân tích
- `name` là `private` → **Encapsulation**
- `Dog extends Animal`, `Cat extends Animal` → **Inheritance**
- `Animal` có `abstract sound()` → **Abstraction**
- `a1.sound()` và `a2.sound()` chạy khác nhau → **Polymorphism**

---

## 8) Các câu hỏi phỏng vấn hay gặp

### Câu 1: Hãy kể tên 4 tính chất OOP trong Java
Trả lời:
> Encapsulation, Inheritance, Polymorphism, và Abstraction.

### Câu 2: Encapsulation là gì
Trả lời:
> Là cơ chế đóng gói dữ liệu và hành vi vào trong class, đồng thời giới hạn truy cập trực tiếp vào dữ liệu bằng access modifier và cung cấp quyền truy cập có kiểm soát.

### Câu 3: Abstraction khác gì Encapsulation
Trả lời:
> Encapsulation tập trung vào việc giấu dữ liệu và bảo vệ trạng thái object. Abstraction tập trung vào việc giấu chi tiết cài đặt và chỉ cung cấp hành vi cần thiết.

### Câu 4: Java có đa kế thừa class không
Trả lời:
> Không. Java không hỗ trợ multiple inheritance với class, nhưng hỗ trợ implement nhiều interface.

### Câu 5: Polymorphism có mấy loại
Trả lời:
> Thường chia thành compile-time polymorphism qua overloading và runtime polymorphism qua overriding.

### Câu 6: Interface và abstract class khác nhau thế nào
Trả lời ngắn:
> Interface phù hợp để định nghĩa contract. Abstract class phù hợp khi muốn chia sẻ cả state lẫn behavior chung giữa các class con.

---

## 9) Câu trả lời mẫu 1 phút

Nếu nhà tuyển dụng hỏi:
**“Em hãy trình bày 4 tính chất hướng đối tượng trong Java.”**

Bạn có thể trả lời như sau:

> Trong Java, 4 tính chất OOP gồm Encapsulation, Inheritance, Polymorphism và Abstraction. Encapsulation là đóng gói dữ liệu, thường dùng `private` để bảo vệ trạng thái object và cho truy cập qua method. Inheritance là kế thừa, cho phép class con dùng lại và mở rộng hành vi từ class cha qua `extends`. Polymorphism là đa hình, tức cùng một lời gọi method nhưng hành vi có thể khác nhau tùy object thực tế, thường thấy qua overriding. Abstraction là trừu tượng, tức chỉ lộ ra hành vi cần thiết và ẩn chi tiết cài đặt, thường dùng interface hoặc abstract class. Bốn tính chất này kết hợp với nhau giúp code dễ mở rộng, dễ bảo trì và mô hình hóa hệ thống tốt hơn.

---

## 10) Bẫy phỏng vấn hay gặp

- nghĩ encapsulation chỉ là getter/setter
- nhầm abstraction với encapsulation
- nghĩ overloading cũng quan trọng ngang overriding trong mọi câu hỏi về đa hình
- lạm dụng inheritance thay vì composition
- không phân biệt interface với abstract class
- không giải thích được ví dụ thực tế

---

## 11) Ví dụ thực tế dễ nhớ

### Encapsulation
ATM không cho bạn sửa số dư trực tiếp, phải qua thao tác hợp lệ như rút tiền, nạp tiền.

### Inheritance
`Dog` là một `Animal`.

### Polymorphism
Nút “thanh toán” nhưng tùy phương thức:
- thẻ
- ví điện tử
- chuyển khoản  
thì xử lý khác nhau.

### Abstraction
Bạn bấm nút gửi email, không cần biết bên trong dùng SMTP, queue, retry hay log như thế nào.

---

## 12) Mẹo nhớ cực ngắn

- **Encapsulation** → giấu **dữ liệu**
- **Abstraction** → giấu **cách làm**
- **Inheritance** → **kế thừa**
- **Polymorphism** → **cùng lời gọi, khác hành vi**

---

## 13) Bộ câu hỏi tự luyện

Bạn thử tự trả lời miệng các câu này:

1. 4 tính chất OOP là gì?
2. Encapsulation là gì? Cho ví dụ Java.
3. Abstraction là gì? Dùng interface hay abstract class khi nào?
4. Inheritance là gì? Java có đa kế thừa class không?
5. Polymorphism là gì? Khác overloading và overriding thế nào?
6. Encapsulation khác Abstraction ra sao?
7. Khi nào nên dùng composition thay vì inheritance?
8. Cho ví dụ thực tế của từng tính chất.

---

## 14) Cách học để đi phỏng vấn

Bạn nên học theo thứ tự này:

### Mức 1
- thuộc 4 định nghĩa ngắn
- hiểu 1 ví dụ Java cho mỗi tính chất

### Mức 2
- phân biệt encapsulation vs abstraction
- phân biệt overloading vs overriding
- biết interface vs abstract class

### Mức 3
- trả lời được ví dụ thực tế
- biết nói khi nào không nên lạm dụng inheritance
