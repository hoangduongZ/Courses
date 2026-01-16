# Task 1 — Mindset: Khi nào CẦN Pattern, khi nào KHÔNG CẦN

> **Mục tiêu học:** Sau bài này, bạn sẽ biết đánh giá một đoạn code có cần refactor sang pattern hay không, tránh lạm dụng pattern làm code phức tạp thừa.

---

## 1. Nguyên tắc vàng: Pattern là GIẢI PHÁP, không phải MỤC TIÊU

### ❌ SAI LẦM PHỔ BIẾN
```
"Mình học xong Singleton, giờ phải tìm chỗ áp dụng!"
"Code này chưa có Factory thì chưa professional!"
"Senior bảo phải dùng Strategy pattern, nên mình cứ thêm vào!"
```

### ✅ Tư DUY ĐÚNG
```
"Code này có vấn đề gì? → Có pattern nào giải quyết tốt không?"
"Nếu không dùng pattern, code sẽ khó maintain như thế nào?"
"Chi phí thêm pattern vs lợi ích của nó, cái nào lớn hơn?"
```

**Nguyên tắc:** Pattern phải **giải quyết vấn đề thực tế**, không phải để khoe kỹ thuật.

---

## 2. DẤU HIỆU CẦN PATTERN (Code Smells)

### 🚩 Dấu hiệu 1: CODE LẶP (Duplication)
**Ví dụ:**
```java
// BAD: Lặp logic xử lý payment ở nhiều nơi
public void processVNPayPayment(Order order) {
    // validate order
    // call VNPay API
    // update order status
    // send notification
}

public void processMoMoPayment(Order order) {
    // validate order (SAME)
    // call MoMo API
    // update order status (SAME)
    // send notification (SAME)
}
```

**→ CẦN:** Template Method hoặc Strategy để gom logic chung.

---

### 🚩 Dấu hiệu 2: NHIỀU IF-ELSE THEO LOẠI (Type-based branching)
**Ví dụ:**
```java
// BAD: Mỗi lần thêm payment method mới phải sửa method này
public void processPayment(String type, Order order) {
    if (type.equals("VNPAY")) {
        // VNPay logic
    } else if (type.equals("MOMO")) {
        // MoMo logic
    } else if (type.equals("STRIPE")) {
        // Stripe logic
    } // ... thêm 10 payment nữa → method khổng lồ
}
```

**→ CẦN:** Factory + Strategy để tách từng loại ra.

---

### 🚩 Dấu hiệu 3: KHÓ TEST (Hard to test)
**Ví dụ:**
```java
// BAD: Không thể test OrderService mà không gọi DB thật
public class OrderService {
    public void createOrder(Order order) {
        Connection conn = DriverManager.getConnection("jdbc:mysql://...");
        // insert order vào DB
        
        HttpClient client = HttpClient.newHttpClient();
        // gọi API email service
    }
}
```

**→ CẦN:** Dependency Injection để inject mock DB và email client khi test.

---

### 🚩 Dấu hiệu 4: PHỤ THUỘC CHẶT (Tight Coupling)
**Ví dụ:**
```java
// BAD: OrderService phụ thuộc trực tiếp vào MySQLOrderRepo
public class OrderService {
    private MySQLOrderRepo repo = new MySQLOrderRepo();
    
    public void save(Order order) {
        repo.insert(order); // Không thể đổi sang PostgreSQL
    }
}
```

**→ CẦN:** Repository interface + DI để dễ thay implementation.

---

### 🚩 Dấu hiệu 5: THAY ĐỔI THƯỜNG XUYÊN (Frequent changes)
**Ví dụ:**
```java
// Business rule tính discount thay đổi mỗi tuần
public double calculateDiscount(Order order) {
    if (order.customer.isVIP()) {
        return order.total * 0.2;
    } else if (order.total > 1000000) {
        return order.total * 0.1;
    } else if (isBlackFriday()) {
        return order.total * 0.3;
    }
    // Marketing yêu cầu thêm rule mới mỗi tuần...
}
```

**→ CẦN:** Strategy hoặc Specification để dễ thêm rule mới mà không sửa code cũ.

---

## 3. DẤU HIỆU KHÔNG CẦN PATTERN

### ✋ Trường hợp 1: LOGIC ĐƠN GIẢN, STABLE
**Ví dụ:**
```java
// OK: Logic rõ ràng, ít khi thay đổi
public String formatCurrency(double amount) {
    return "₫" + String.format("%,.0f", amount);
}
```

**→ KHÔNG CẦN:** Đừng tạo `CurrencyFormatterFactory` cho cái này!

---

### ✋ Trường hợp 2: DEADLINE GẤP, POC/MVP
**Tình huống:**
- Team 2 người, deadline 1 tuần
- Làm POC để demo cho khách hàng
- Feature này có thể bỏ sau 1 tháng

**→ KHÔNG CẦN:** Viết code đơn giản, hoạt động là được. Refactor sau nếu feature được giữ lại.

---

### ✋ Trường hợp 3: CHỈ CÓ 1 IMPLEMENTATION
**Ví dụ:**
```java
// BAD: Tạo interface cho 1 class duy nhất
public interface EmailService {
    void send(String to, String subject);
}

public class GmailEmailService implements EmailService {
    // ... implementation
}
```

**→ KHÔNG CẦN:** Chỉ tạo interface khi:
- Có ≥2 implementations (Gmail, SendGrid)
- Hoặc cần mock để test

---

### ✋ Trường hợp 4: TEAM NHỎ, CODE THIỂU
**Tình huống:**
- Script tool nội bộ, chỉ 1 developer maintain
- Code < 500 dòng
- Không có plan mở rộng

**→ KHÔNG CẦN:** Procedural code đơn giản dễ hiểu hơn.

---

## 4. BA TIÊU CHÍ ENTERPRISE (Khi nào CẦN nghĩ đến pattern)

### 🎯 Tiêu chí 1: MAINTAINABILITY (Dễ bảo trì)
**Câu hỏi tự vấn:**
- 6 tháng sau, developer khác đọc code này có hiểu không?
- Khi thêm feature mới, có phải sửa nhiều chỗ không?
- Khi fix bug, có risk làm hỏng chỗ khác không?

**Ví dụ cần improve:**
```java
// 1 method 500 dòng, xử lý 10 nghiệp vụ khác nhau
public void handleOrder(Order order) {
    // validate
    // check inventory
    // calculate shipping
    // apply discount
    // process payment
    // send email
    // update analytics
    // ... 500 dòng
}
```

**→ Pattern:** Template Method hoặc Chain of Responsibility.

---

### 🎯 Tiêu chí 2: TESTABILITY (Dễ test)
**Câu hỏi tự vấn:**
- Có thể test method này mà không cần DB/API thật không?
- Có thể test từng case độc lập không?
- Setup test có đơn giản không?

**Ví dụ cần improve:**
```java
// Không thể test vì phụ thuộc static method
public class PriceCalculator {
    public double calculate(Order order) {
        double tax = TaxService.getTax(); // static call
        double shipping = ShippingCalculator.calculate(order.weight);
        return order.total + tax + shipping;
    }
}
```

**→ Pattern:** Dependency Injection.

---

### 🎯 Tiêu chí 3: EXTENSIBILITY (Dễ mở rộng)
**Câu hỏi tự vấn:**
- Thêm feature mới có phải sửa code cũ không?
- Có tuân thủ Open/Closed Principle không?
- Có thể plug-in thêm module không?

**Ví dụ cần improve:**
```java
// Mỗi lần thêm notification channel phải sửa code
public void notify(String message) {
    sendEmail(message);
    sendSMS(message);
    // Nếu thêm push notification → phải sửa method này
}
```

**→ Pattern:** Observer/PubSub để subscribe nhiều handlers.

---

## 5. NGUYÊN TẮC: "Prefer Composition over Inheritance"

### ❌ INHERITANCE (Kế thừa) - DỄ LẠM DỤNG

**Vấn đề:**
```java
// BAD: Hierarchy phình to khi có nhiều variation
class Animal { }
class Dog extends Animal { }
class Robot { }
class RobotDog extends ??? // Kế thừa Dog hay Robot?

// Hoặc:
class Employee { }
class Manager extends Employee { }
class Developer extends Employee { }
class ManagerDeveloper extends ??? // Vừa làm manager vừa code?
```

**Hệ quả:**
- Hierarchy phình to, khó hiểu
- Rigid: thay đổi base class ảnh hưởng tất cả
- Không linh hoạt khi object có nhiều "role"

---

### ✅ COMPOSITION (Kết hợp) - LINH HOẠT HƠN

**Giải pháp:**
```java
// GOOD: Compose behaviors
class Employee {
    private Role role; // Manager, Developer, QA...
    private Level level; // Junior, Senior...
    private List<Skill> skills;
    
    public void work() {
        role.performDuties();
    }
}

interface Role {
    void performDuties();
}

class ManagerRole implements Role {
    public void performDuties() { /* manage team */ }
}

class DeveloperRole implements Role {
    public void performDuties() { /* write code */ }
}
```

**Lợi ích:**
- Linh hoạt: 1 employee có thể có nhiều roles
- Dễ test: test từng role độc lập
- Dễ mở rộng: thêm role mới không ảnh hưởng code cũ

**Kết luận:** Dùng inheritance khi:
- Là "IS-A" rõ ràng (Dog IS-A Animal)
- Hierarchy ổn định, ít thay đổi

Dùng composition khi:
- Nhiều variations/combinations
- Cần linh hoạt thay đổi behavior runtime

---

## 6. WORKFLOW RA QUYẾT ĐỊNH (Decision Tree)

```
Code có vấn đề không?
│
├─ KHÔNG → Giữ nguyên, đừng refactor sớm
│
└─ CÓ → Vấn đề gì?
    │
    ├─ Code lặp → Template Method / Strategy
    ├─ Nhiều if-else theo type → Factory / Strategy
    ├─ Khó test → Dependency Injection
    ├─ Phụ thuộc chặt → Interface + DI / Adapter
    ├─ Thay đổi thường xuyên → Strategy / Specification
    ├─ Cần mở rộng mà không sửa → Open/Closed → Observer / Decorator
    │
    └─ Cân nhắc chi phí:
        │
        ├─ Pattern có giải quyết vấn đề không? → KHÔNG → Tìm cách khác
        ├─ Team có hiểu pattern này không? → KHÔNG → Đào tạo hoặc dùng cách đơn giản hơn
        ├─ Deadline cho phép không? → KHÔNG → Viết đơn giản, refactor sau
        └─ ROI có cao không? → CÓ → Áp dụng pattern
```

---

## 7. BÀI TẬP THỰC HÀNH

### Bài 1: ĐÁNH GIÁ CODE NÀO CẦN REFACTOR

**Code mẫu A:**
```java
public class ReportGenerator {
    public void generate(String type, Data data) {
        if (type.equals("PDF")) {
            // 50 dòng logic PDF
        } else if (type.equals("EXCEL")) {
            // 50 dòng logic Excel
        } else if (type.equals("CSV")) {
            // 50 dòng logic CSV
        }
    }
}
```

**Câu hỏi:**
1. Code này có vấn đề gì?
2. Nếu thêm format JSON, phải sửa ở đâu?
3. Làm sao test chỉ logic PDF mà không chạy Excel/CSV?
4. Pattern nào phù hợp?

---

**Code mẫu B:**
```java
public class Authenticator {
    private PasswordEncoder encoder;
    private UserRepository repo;
    
    public Authenticator(PasswordEncoder encoder, UserRepository repo) {
        this.encoder = encoder;
        this.repo = repo;
    }
    
    public boolean authenticate(String username, String password) {
        User user = repo.findByUsername(username);
        return user != null && encoder.matches(password, user.getPassword());
    }
}
```

**Câu hỏi:**
1. Code này có cần refactor thêm pattern không? Tại sao?
2. Code này có dễ test không?
3. Nếu thêm feature "login bằng email", có phải sửa nhiều không?

---

### Bài 2: CHỌN GIẢI PHÁP PHÙ HỢP

**Tình huống:** Bạn làm hệ thống quản lý đơn hàng, có yêu cầu:
- Gửi email thông báo khi order thành công
- Cập nhật inventory
- Ghi log analytics
- Tính điểm loyalty
- **NHƯNG:** Product Owner nói có thể thay đổi/bỏ/thêm step tuần sau

**Câu hỏi:**
1. Viết tất cả logic trong 1 method `createOrder()` có ổn không? Tại sao?
2. Pattern nào giúp dễ thêm/bớt step?
3. Nếu deadline chỉ còn 2 ngày, bạn sẽ làm gì?

---

### Bài 3: PHÂN BIỆT INHERITANCE VS COMPOSITION

**Yêu cầu:** Thiết kế hệ thống quản lý phương tiện (Vehicle)
- Có: Car, Truck, Motorcycle
- Mỗi loại có: petrol engine hoặc electric engine
- Mỗi loại có thể: manual transmission hoặc automatic

**Câu hỏi:**
1. Dùng inheritance thiết kế như thế nào? Vẽ class diagram.
2. Có vấn đề gì khi có 3 loại × 2 engine × 2 transmission = 12 classes?
3. Dùng composition thiết kế như thế nào?
4. Cách nào linh hoạt hơn khi thêm "hybrid engine"?

---

## 8. CHECKLIST TỰ ĐÁNH GIÁ

Sau Task 1, bạn check xem đã đạt được chưa:

- [ ] Hiểu pattern là giải pháp, không phải mục tiêu
- [ ] Nhận diện được 5 dấu hiệu cần pattern (code smells)
- [ ] Nhận diện được 4 trường hợp KHÔNG nên dùng pattern
- [ ] Hiểu 3 tiêu chí enterprise: maintainability, testability, extensibility
- [ ] Hiểu "composition over inheritance" và khi nào dùng cái nào
- [ ] Có thể đánh giá 1 đoạn code có cần refactor hay không
- [ ] Biết cân nhắc ROI (chi phí vs lợi ích) khi áp dụng pattern

---

## 9. TÀI LIỆU THAM KHẢO

**Đọc thêm:**
- Martin Fowler - "Refactoring" (Chapter: Code Smells)
- Robert C. Martin - "Clean Code" (Chapter: Functions, Classes)
- Gang of Four - "Design Patterns" (Introduction: When to use patterns)

**Video hay:**
- "The Art of Code" - Dylan Beattie (về khi nào code đơn giản là tốt nhất)
- "All the Little Things" - Sandi Metz (composition over inheritance)

---

## KẾT LUẬN TASK 1

**Nhớ kỹ:**
1. **ROI > Perfection:** Pattern phải mang lại giá trị, không phải làm đẹp code
2. **Simple > Complex:** Khi phân vân, chọn cách đơn giản trước
3. **Refactor when needed:** Đừng refactor sớm, đợi vấn đề rõ ràng
4. **Team context matters:** Pattern phải phù hợp với trình độ team

**Câu nói hay:**
> "You Aren't Gonna Need It" (YAGNI) - đừng thêm code cho tương lai mơ hồ
>
> "Make it work, make it right, make it fast" - Kent Beck

---

**Next:** Khi đã nắm mindset này, chuyển sang Task 2: Dependency Injection - pattern cốt lõi nhất enterprise!
