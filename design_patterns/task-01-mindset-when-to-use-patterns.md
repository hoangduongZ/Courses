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

## 10. ĐÁP ÁN BÀI TẬP THỰC HÀNH

### ĐÁP ÁN BÀI 1: ĐÁNH GIÁ CODE NÀO CẦN REFACTOR

#### Code mẫu A - ReportGenerator

**1. Code này có vấn đề gì?**

Có **4 vấn đề chính:**

- ✗ **Violate Open/Closed Principle:** Mỗi lần thêm format mới (JSON, XML) phải sửa method `generate()`
- ✗ **God Method:** 1 method xử lý nhiều trách nhiệm khác nhau
- ✗ **Khó test:** Không thể test riêng logic PDF mà không có code Excel/CSV
- ✗ **Code duplication potential:** Logic chung (load data, validate) có thể lặp ở mỗi nhánh

**2. Nếu thêm format JSON, phải sửa ở đâu?**

Phải sửa method `generate()`:
```java
// Phải thêm nhánh if mới
if (type.equals("PDF")) {
    // ...
} else if (type.equals("EXCEL")) {
    // ...
} else if (type.equals("CSV")) {
    // ...
} else if (type.equals("JSON")) { // ← THÊM MỚI
    // 50 dòng logic JSON
}
```

**Rủi ro:** Có thể làm hỏng logic cũ (PDF/Excel/CSV) khi thêm code mới.

**3. Làm sao test chỉ logic PDF mà không chạy Excel/CSV?**

**Không thể** với thiết kế hiện tại! Vì:
- Tất cả logic nằm trong 1 method
- Phải pass `type = "PDF"` và hi vọng không có bug ở nhánh Excel/CSV

**4. Pattern nào phù hợp?**

**Giải pháp: Strategy Pattern + Factory**

```java
// Step 1: Tạo interface cho Strategy
public interface ReportGenerator {
    void generate(Data data);
}

// Step 2: Mỗi format = 1 implementation
public class PdfReportGenerator implements ReportGenerator {
    @Override
    public void generate(Data data) {
        // 50 dòng logic PDF - TÁCH RỜI
    }
}

public class ExcelReportGenerator implements ReportGenerator {
    @Override
    public void generate(Data data) {
        // 50 dòng logic Excel - TÁCH RỜI
    }
}

public class CsvReportGenerator implements ReportGenerator {
    @Override
    public void generate(Data data) {
        // 50 dòng logic CSV - TÁCH RỜI
    }
}

// Step 3: Factory để chọn generator
public class ReportGeneratorFactory {
    private static final Map<String, ReportGenerator> generators = Map.of(
        "PDF", new PdfReportGenerator(),
        "EXCEL", new ExcelReportGenerator(),
        "CSV", new CsvReportGenerator()
    );
    
    public static ReportGenerator getGenerator(String type) {
        ReportGenerator generator = generators.get(type);
        if (generator == null) {
            throw new IllegalArgumentException("Unsupported format: " + type);
        }
        return generator;
    }
}

// Step 4: Sử dụng
public class ReportService {
    public void generateReport(String type, Data data) {
        ReportGenerator generator = ReportGeneratorFactory.getGenerator(type);
        generator.generate(data);
    }
}
```

**Lợi ích:**
- ✓ **Open/Closed:** Thêm JSON chỉ cần tạo `JsonReportGenerator` và đăng ký vào Factory, không sửa code cũ
- ✓ **Dễ test:** Test `PdfReportGenerator` độc lập, không cần quan tâm Excel/CSV
- ✓ **Single Responsibility:** Mỗi class chỉ lo 1 format
- ✓ **Maintainability:** Bug ở PDF không ảnh hưởng Excel

---

#### Code mẫu B - Authenticator

**1. Code này có cần refactor thêm pattern không? Tại sao?**

**KHÔNG CẦN refactor thêm pattern!** Vì:

- ✓ **Đã dùng DI đúng:** Constructor injection cho dependencies
- ✓ **Single Responsibility:** Chỉ lo authentication
- ✓ **Dễ test:** Có thể inject mock `PasswordEncoder` và `UserRepository`
- ✓ **Loose coupling:** Phụ thuộc vào interface, không phụ thuộc implementation cụ thể
- ✓ **Code rõ ràng:** Logic đơn giản, dễ hiểu

**Đây là ví dụ GOOD CODE - không cần pattern thêm!**

**2. Code này có dễ test không?**

**RẤT DỄ TEST:**

```java
// Unit test ví dụ
@Test
public void testAuthenticate_Success() {
    // Arrange: Tạo mocks
    PasswordEncoder mockEncoder = mock(PasswordEncoder.class);
    UserRepository mockRepo = mock(UserRepository.class);
    
    User user = new User("john", "$hashed_password");
    when(mockRepo.findByUsername("john")).thenReturn(user);
    when(mockEncoder.matches("123456", "$hashed_password")).thenReturn(true);
    
    Authenticator auth = new Authenticator(mockEncoder, mockRepo);
    
    // Act
    boolean result = auth.authenticate("john", "123456");
    
    // Assert
    assertTrue(result);
}

@Test
public void testAuthenticate_WrongPassword() {
    PasswordEncoder mockEncoder = mock(PasswordEncoder.class);
    UserRepository mockRepo = mock(UserRepository.class);
    
    User user = new User("john", "$hashed_password");
    when(mockRepo.findByUsername("john")).thenReturn(user);
    when(mockEncoder.matches("wrong", "$hashed_password")).thenReturn(false);
    
    Authenticator auth = new Authenticator(mockEncoder, mockRepo);
    
    boolean result = auth.authenticate("john", "wrong");
    
    assertFalse(result);
}
```

**Không cần DB thật, không cần setup phức tạp!**

**3. Nếu thêm feature "login bằng email", có phải sửa nhiều không?**

**CÓ 2 CÁCH:**

**Cách 1: Mở rộng đơn giản (nếu logic tương tự)**
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
    
    // Thêm method mới - không ảnh hưởng method cũ
    public boolean authenticateByEmail(String email, String password) {
        User user = repo.findByEmail(email);
        return user != null && encoder.matches(password, user.getPassword());
    }
}
```

**Cách 2: Nếu có nhiều cách login khác nhau → dùng Strategy**
```java
// Nếu sau này có: login by phone, login by OAuth, login by fingerprint...
public interface AuthenticationStrategy {
    boolean authenticate(String credential, String secret);
}

public class UsernamePasswordAuth implements AuthenticationStrategy {
    private PasswordEncoder encoder;
    private UserRepository repo;
    
    @Override
    public boolean authenticate(String username, String password) {
        User user = repo.findByUsername(username);
        return user != null && encoder.matches(password, user.getPassword());
    }
}

public class EmailPasswordAuth implements AuthenticationStrategy {
    // Similar implementation
}
```

**Kết luận:** Với yêu cầu hiện tại, **Cách 1 đủ dùng**. Chỉ dùng Strategy khi thực sự có ≥3 cách login khác nhau.

---

### ĐÁP ÁN BÀI 2: CHỌN GIẢI PHÁP PHÙ HỢP

**Tình huống:** Order system với nhiều steps có thể thay đổi.

**1. Viết tất cả logic trong 1 method `createOrder()` có ổn không? Tại sao?**

**KHÔNG ỔN!** Vì:

```java
// BAD APPROACH
public void createOrder(Order order) {
    // validate order
    
    // save to DB
    
    // send email
    
    // update inventory
    
    // log analytics
    
    // calculate loyalty points
    
    // ... 200 dòng code
}
```

**Vấn đề:**
- ✗ **God Method:** 1 method làm quá nhiều việc
- ✗ **Khó test:** Phải mock email, inventory, analytics, loyalty cùng lúc
- ✗ **Khó mở rộng:** Product Owner muốn thêm "send SMS" → phải sửa method này
- ✗ **Khó maintain:** Bug ở phần email có thể ảnh hưởng inventory
- ✗ **Violate Single Responsibility:** Mỗi step là 1 trách nhiệm riêng

**2. Pattern nào giúp dễ thêm/bớt step?**

**Giải pháp 1: Chain of Responsibility (Pipeline)**

```java
// Step 1: Interface cho handler
public interface OrderHandler {
    void handle(Order order);
}

// Step 2: Mỗi step = 1 handler
public class ValidateOrderHandler implements OrderHandler {
    @Override
    public void handle(Order order) {
        // validation logic
    }
}

public class SaveOrderHandler implements OrderHandler {
    private OrderRepository repo;
    
    @Override
    public void handle(Order order) {
        repo.save(order);
    }
}

public class SendEmailHandler implements OrderHandler {
    private EmailService emailService;
    
    @Override
    public void handle(Order order) {
        emailService.send(order.getCustomerEmail(), "Order created!");
    }
}

public class UpdateInventoryHandler implements OrderHandler {
    private InventoryService inventoryService;
    
    @Override
    public void handle(Order order) {
        inventoryService.decreaseStock(order.getItems());
    }
}

// Step 3: Pipeline coordinator
public class OrderPipeline {
    private List<OrderHandler> handlers;
    
    public OrderPipeline(List<OrderHandler> handlers) {
        this.handlers = handlers;
    }
    
    public void process(Order order) {
        for (OrderHandler handler : handlers) {
            handler.handle(order);
        }
    }
}

// Step 4: Configuration
public class OrderService {
    private OrderPipeline pipeline;
    
    public OrderService() {
        // Dễ dàng thêm/bớt/thay đổi thứ tự handlers
        this.pipeline = new OrderPipeline(List.of(
            new ValidateOrderHandler(),
            new SaveOrderHandler(),
            new SendEmailHandler(),
            new UpdateInventoryHandler(),
            new LogAnalyticsHandler(),
            new CalculateLoyaltyHandler()
        ));
    }
    
    public void createOrder(Order order) {
        pipeline.process(order);
    }
}
```

**Giải pháp 2: Observer/Event Pattern (Nếu steps có thể chạy async)**

```java
// Step 1: Domain event
public class OrderCreatedEvent {
    private Order order;
    private LocalDateTime createdAt;
    
    // constructor, getters...
}

// Step 2: Event listeners
@Component
public class EmailNotificationListener {
    @EventListener
    public void onOrderCreated(OrderCreatedEvent event) {
        emailService.send(event.getOrder().getCustomerEmail(), "Order created!");
    }
}

@Component
public class InventoryUpdateListener {
    @EventListener
    public void onOrderCreated(OrderCreatedEvent event) {
        inventoryService.decreaseStock(event.getOrder().getItems());
    }
}

@Component
public class LoyaltyPointsListener {
    @EventListener
    public void onOrderCreated(OrderCreatedEvent event) {
        loyaltyService.addPoints(event.getOrder());
    }
}

// Step 3: Service publish event
public class OrderService {
    private ApplicationEventPublisher eventPublisher;
    
    public void createOrder(Order order) {
        // Core logic: validate + save
        validateOrder(order);
        orderRepository.save(order);
        
        // Publish event → all listeners tự động chạy
        eventPublisher.publishEvent(new OrderCreatedEvent(order));
    }
}
```

**So sánh:**
- **Chain of Responsibility:** Thích hợp khi steps phải chạy **tuần tự, đồng bộ**
- **Observer/Events:** Thích hợp khi steps có thể chạy **bất đồng bộ, độc lập**

**3. Nếu deadline chỉ còn 2 ngày, bạn sẽ làm gì?**

**THỰC DỤNG:**

```java
// Version 1.0: Đơn giản nhưng đủ dùng
public class OrderService {
    private OrderRepository repo;
    private EmailService emailService;
    private InventoryService inventoryService;
    
    public void createOrder(Order order) {
        // Validate
        if (order.getItems().isEmpty()) {
            throw new IllegalArgumentException("Order must have items");
        }
        
        // Save
        repo.save(order);
        
        // Email
        emailService.send(order.getCustomerEmail(), "Order created!");
        
        // Inventory
        inventoryService.decreaseStock(order.getItems());
    }
}
```

**Lý do:**
- ✓ Code đơn giản, dễ hiểu, dễ debug
- ✓ Đủ để demo/ship feature
- ✓ Tiết kiệm thời gian cho deadline

**SAU ĐÓ (khi feature stable):**
- Refactor sang Chain of Responsibility/Events nếu thấy cần thiết
- Theo nguyên tắc: **Make it work → Make it right → Make it fast**

**Lưu ý:** Nếu requirements rõ ràng là "sẽ thêm nhiều steps", thì nên dùng pattern từ đầu. Nhưng nếu chưa chắc, **code đơn giản trước**.

---

### ĐÁP ÁN BÀI 3: INHERITANCE VS COMPOSITION

**Yêu cầu:** Vehicle system với nhiều variations.

**1. Dùng inheritance thiết kế như thế nào?**

```
                    Vehicle
                       |
        +-------------+-------------+
        |             |             |
      Car          Truck      Motorcycle
        |             |             |
   +----+----+   +----+----+   +----+----+
   |         |   |         |   |         |
PetrolCar ElectricCar PetrolTruck ElectricTruck ...
   |         |
+--+--+   +--+--+
|     |   |     |
ManualPetrolCar AutoPetrolCar ManualElectricCar AutoElectricCar
```

**Kết quả: Class Explosion!**
- 3 vehicle types × 2 engines × 2 transmissions = **12 classes**
- Chưa kể: diesel engine, hybrid, CVT transmission...

**2. Có vấn đề gì?**

**Vấn đề nghiêm trọng:**

- ✗ **Class Explosion:** Mỗi combination = 1 class mới
- ✗ **Code Duplication:** Logic transmission giống nhau ở Manual*Car và Manual*Truck
- ✗ **Rigid Hierarchy:** Thay đổi `Vehicle` ảnh hưởng tất cả
- ✗ **Không linh hoạt:** Làm sao tạo "car vừa có petrol engine vừa có electric" (hybrid)?
- ✗ **Khó maintain:** Bug ở automatic transmission → phải fix ở 6 classes khác nhau

**Ví dụ code duplication:**
```java
class ManualPetrolCar extends PetrolCar {
    public void shiftGear() {
        // logic manual transmission
    }
}

class ManualPetrolTruck extends PetrolTruck {
    public void shiftGear() {
        // SAME logic manual transmission - DUPLICATED!
    }
}
```

**3. Dùng composition thiết kế như thế nào?**

**Giải pháp: Compose behaviors**

```java
// Step 1: Tách behavior thành interfaces
public interface Engine {
    void start();
    void stop();
    int getPower();
}

public interface Transmission {
    void shiftGear(int gear);
    String getType();
}

// Step 2: Implementations
public class PetrolEngine implements Engine {
    @Override
    public void start() {
        System.out.println("Petrol engine started");
    }
    
    @Override
    public int getPower() {
        return 150; // HP
    }
}

public class ElectricEngine implements Engine {
    @Override
    public void start() {
        System.out.println("Electric engine started silently");
    }
    
    @Override
    public int getPower() {
        return 200; // HP
    }
}

public class ManualTransmission implements Transmission {
    @Override
    public void shiftGear(int gear) {
        System.out.println("Manual shift to gear " + gear);
    }
}

public class AutomaticTransmission implements Transmission {
    @Override
    public void shiftGear(int gear) {
        System.out.println("Auto shift to gear " + gear);
    }
}

// Step 3: Vehicle compose behaviors
public abstract class Vehicle {
    protected Engine engine;
    protected Transmission transmission;
    protected String model;
    
    public Vehicle(Engine engine, Transmission transmission, String model) {
        this.engine = engine;
        this.transmission = transmission;
        this.model = model;
    }
    
    public void start() {
        engine.start();
    }
    
    public void drive() {
        start();
        transmission.shiftGear(1);
        System.out.println(model + " is driving");
    }
}

public class Car extends Vehicle {
    public Car(Engine engine, Transmission transmission, String model) {
        super(engine, transmission, model);
    }
    
    public void openTrunk() {
        System.out.println("Trunk opened");
    }
}

public class Truck extends Vehicle {
    private int loadCapacity;
    
    public Truck(Engine engine, Transmission transmission, String model, int loadCapacity) {
        super(engine, transmission, model);
        this.loadCapacity = loadCapacity;
    }
    
    public void loadCargo(int weight) {
        System.out.println("Loading " + weight + "kg cargo");
    }
}

// Step 4: Usage - Linh hoạt tạo combinations
public class Main {
    public static void main(String[] args) {
        // Manual petrol car
        Vehicle car1 = new Car(
            new PetrolEngine(),
            new ManualTransmission(),
            "Toyota Corolla"
        );
        
        // Auto electric car
        Vehicle car2 = new Car(
            new ElectricEngine(),
            new AutomaticTransmission(),
            "Tesla Model 3"
        );
        
        // Manual electric truck
        Vehicle truck1 = new Truck(
            new ElectricEngine(),
            new ManualTransmission(),
            "Rivian R1T",
            1000
        );
        
        car1.drive();
        car2.drive();
        truck1.drive();
    }
}
```

**Kết quả: Chỉ cần:**
- 3 vehicle classes (Car, Truck, Motorcycle)
- 2 engine implementations (Petrol, Electric)
- 2 transmission implementations (Manual, Auto)

**Tổng: 7 classes thay vì 12!**

**4. Cách nào linh hoạt hơn khi thêm "hybrid engine"?**

**Với Inheritance:**
```
// Phải tạo thêm 6 classes mới:
HybridCar
  ├─ ManualHybridCar
  └─ AutoHybridCar
HybridTruck
  ├─ ManualHybridTruck
  └─ AutoHybridTruck
HybridMotorcycle
  └─ ...
```

**Với Composition:**
```java
// Chỉ cần thêm 1 class duy nhất!
public class HybridEngine implements Engine {
    private PetrolEngine petrolEngine;
    private ElectricEngine electricEngine;
    private boolean useElectric;
    
    @Override
    public void start() {
        if (useElectric) {
            electricEngine.start();
        } else {
            petrolEngine.start();
        }
    }
    
    public void switchMode() {
        useElectric = !useElectric;
    }
}

// Sử dụng ngay với bất kỳ vehicle nào
Vehicle hybridCar = new Car(
    new HybridEngine(),
    new AutomaticTransmission(),
    "Toyota Prius"
);
```

**Hoặc thậm chí runtime switching:**
```java
Vehicle car = new Car(
    new PetrolEngine(),
    new ManualTransmission(),
    "Honda Civic"
);

// Sau này đổi engine
car.engine = new ElectricEngine(); // Nếu có setter
```

**KẾT LUẬN:**

| Tiêu chí | Inheritance | Composition |
|----------|-------------|-------------|
| Số classes | 12+ (explosion) | 7 (compact) |
| Thêm variation | Phải tạo nhiều classes | Chỉ thêm 1 implementation |
| Code duplication | Cao | Thấp |
| Linh hoạt | Thấp (rigid hierarchy) | Cao (mix & match) |
| Testability | Khó (phải test nhiều classes) | Dễ (test từng component) |
| Maintainability | Khó (phải sửa nhiều chỗ) | Dễ (sửa 1 chỗ) |

**→ Composition wins!** Đặc biệt trong enterprise khi requirements thay đổi thường xuyên.

**Khi nào dùng Inheritance:**
- Relationship IS-A rõ ràng: Dog IS-A Animal
- Hierarchy ổn định: Shape → Circle, Rectangle (ít khi thay đổi)
- Cần override behavior cụ thể của parent

**Khi nào dùng Composition:**
- Nhiều variations/combinations: Vehicle example
- Cần flexibility: switch behavior runtime
- HAS-A relationship: Car HAS-A Engine, HAS-A Transmission

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
