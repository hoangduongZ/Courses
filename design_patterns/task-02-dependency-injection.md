# Task 2 — Dependency Injection (DI) - Pattern Cốt Lõi Enterprise

> **Mục tiêu học:** Sau bài này, bạn sẽ thành thạo DI - pattern quan trọng nhất enterprise. Biết cách tách dependencies để code dễ test, dễ thay implementation, và tuân thủ SOLID principles.

---

## 1. DEPENDENCY INJECTION LÀ GÌ?

### Định nghĩa đơn giản

**Dependency Injection (DI)** = Đưa dependencies vào class **từ bên ngoài**, thay vì class tự tạo.

### So sánh: Không DI vs Có DI

**❌ KHÔNG DI (Hard-coded dependencies):**
```java
public class OrderService {
    // OrderService TỰ TẠO dependencies
    private OrderRepository repo = new MySQLOrderRepository();
    private EmailService email = new GmailEmailService();
    
    public void createOrder(Order order) {
        repo.save(order);
        email.send(order.getCustomerEmail(), "Order created!");
    }
}
```

**Vấn đề:**
- ✗ **Tight Coupling:** Gắn chặt với MySQL và Gmail
- ✗ **Không thể thay đổi:** Muốn đổi sang PostgreSQL? Phải sửa code!
- ✗ **Không thể test:** Không thể mock repo/email → phải connect DB thật, gửi email thật
- ✗ **Vi phạm Open/Closed Principle**

---

**✅ CÓ DI (Dependencies injected từ bên ngoài):**
```java
public class OrderService {
    private OrderRepository repo;
    private EmailService email;
    
    // Constructor Injection - dependencies được ĐƯA VÀO
    public OrderService(OrderRepository repo, EmailService email) {
        this.repo = repo;
        this.email = email;
    }
    
    public void createOrder(Order order) {
        repo.save(order);
        email.send(order.getCustomerEmail(), "Order created!");
    }
}

// Sử dụng
OrderService service = new OrderService(
    new MySQLOrderRepository(),  // Hoặc PostgreSQLOrderRepository
    new GmailEmailService()      // Hoặc SendGridEmailService
);
```

**Lợi ích:**
- ✓ **Loose Coupling:** OrderService không quan tâm implementation cụ thể
- ✓ **Dễ thay đổi:** Đổi implementation chỉ cần thay ở chỗ khởi tạo
- ✓ **Dễ test:** Inject mock objects khi test
- ✓ **Tuân thủ SOLID:** Dependency Inversion Principle

---

## 2. BA CÁCH INJECTION (Constructor > Setter > Field)

### 2.1. Constructor Injection (ƯU TIÊN - Best Practice)

```java
public class OrderService {
    private final OrderRepository repo;  // final = immutable
    private final EmailService email;
    
    // Inject qua constructor
    public OrderService(OrderRepository repo, EmailService email) {
        this.repo = repo;
        this.email = email;
    }
}
```

**Ưu điểm:**
- ✓ **Immutability:** Dependencies là `final`, không thể thay đổi
- ✓ **Mandatory:** Compiler bắt buộc phải truyền dependencies
- ✓ **Clear contract:** Nhìn constructor là biết class cần gì
- ✓ **Dễ test:** Luôn rõ ràng cần mock gì

**Khi nào dùng:** Luôn luôn (default choice)

---

### 2.2. Setter Injection (Optional dependencies)

```java
public class OrderService {
    private OrderRepository repo;
    private EmailService email;
    private AnalyticsService analytics; // Optional
    
    public OrderService(OrderRepository repo, EmailService email) {
        this.repo = repo;
        this.email = email;
    }
    
    // Setter cho optional dependency
    public void setAnalytics(AnalyticsService analytics) {
        this.analytics = analytics;
    }
    
    public void createOrder(Order order) {
        repo.save(order);
        email.send(order.getCustomerEmail(), "Order created!");
        
        if (analytics != null) {  // Optional
            analytics.track("order_created", order.getId());
        }
    }
}
```

**Ưu điểm:**
- ✓ Cho phép dependencies **không bắt buộc**
- ✓ Cho phép thay đổi dependency sau khi tạo object

**Nhược điểm:**
- ✗ Mutable (có thể thay đổi)
- ✗ Không rõ ràng dependency nào bắt buộc

**Khi nào dùng:** Chỉ cho optional dependencies hoặc circular dependency (hiếm)

---

### 2.3. Field Injection (TRÁNH - Chỉ dùng với framework)

```java
public class OrderService {
    @Autowired  // Spring annotation
    private OrderRepository repo;
    
    @Autowired
    private EmailService email;
    
    // No constructor needed - framework inject trực tiếp vào field
}
```

**Ưu điểm:**
- ✓ Code ngắn gọn

**Nhược điểm:**
- ✗ **Không thể test dễ dàng:** Không thể inject mock qua constructor
- ✗ **Vi phạm encapsulation:** Dependencies không immutable
- ✗ **Phụ thuộc framework:** Không thể tạo object bằng `new`
- ✗ **Ẩn dependencies:** Không rõ class cần gì

**Khi nào dùng:** Chỉ khi framework bắt buộc (Spring legacy code). **TRÁNH trong code mới.**

**Khuyến nghị Spring:**
```java
// GOOD: Spring hỗ trợ constructor injection
@Service
public class OrderService {
    private final OrderRepository repo;
    private final EmailService email;
    
    // Spring tự động inject nếu chỉ có 1 constructor (từ Spring 4.3+)
    public OrderService(OrderRepository repo, EmailService email) {
        this.repo = repo;
        this.email = email;
    }
}
```

---

## 3. INTERFACE/ABSTRACTION - Tách Interface khỏi Implementation

### Nguyên tắc: Depend on Abstractions, Not Concretions

**❌ BAD: Phụ thuộc vào concrete class**
```java
public class OrderService {
    private MySQLOrderRepository repo;  // ← Concrete class
    
    public OrderService(MySQLOrderRepository repo) {
        this.repo = repo;
    }
}
```

**Vấn đề:** Không thể đổi sang PostgreSQL, MongoDB... mà không sửa code.

---

**✅ GOOD: Phụ thuộc vào interface**
```java
// Interface định nghĩa contract
public interface OrderRepository {
    void save(Order order);
    Order findById(String id);
    List<Order> findByCustomer(String customerId);
}

// Implementation 1: MySQL
public class MySQLOrderRepository implements OrderRepository {
    @Override
    public void save(Order order) {
        // JDBC code để save vào MySQL
    }
    
    @Override
    public Order findById(String id) {
        // JDBC code để query MySQL
    }
    
    @Override
    public List<Order> findByCustomer(String customerId) {
        // MySQL specific query
    }
}

// Implementation 2: PostgreSQL
public class PostgreSQLOrderRepository implements OrderRepository {
    @Override
    public void save(Order order) {
        // PostgreSQL specific code
    }
    
    @Override
    public Order findById(String id) {
        // PostgreSQL specific code
    }
    
    @Override
    public List<Order> findByCustomer(String customerId) {
        // PostgreSQL specific code
    }
}

// Service phụ thuộc vào INTERFACE
public class OrderService {
    private final OrderRepository repo;  // ← Interface, not concrete class
    
    public OrderService(OrderRepository repo) {
        this.repo = repo;  // Có thể nhận bất kỳ implementation nào
    }
    
    public void createOrder(Order order) {
        repo.save(order);  // Không quan tâm DB nào
    }
}

// Sử dụng - dễ thay đổi implementation
public class Main {
    public static void main(String[] args) {
        // Development: dùng MySQL
        OrderService service1 = new OrderService(new MySQLOrderRepository());
        
        // Production: đổi sang PostgreSQL - KHÔNG CẦN sửa OrderService
        OrderService service2 = new OrderService(new PostgreSQLOrderRepository());
        
        // Testing: dùng in-memory
        OrderService service3 = new OrderService(new InMemoryOrderRepository());
    }
}
```

**Lợi ích:**
- ✓ **Tuân thủ Dependency Inversion Principle (SOLID)**
- ✓ **Open/Closed:** Thêm implementation mới không sửa OrderService
- ✓ **Dễ test:** Mock interface, không cần DB thật
- ✓ **Flexibility:** Đổi DB chỉ cần thay implementation

---

### Khi nào NÊN tạo interface?

✅ **NÊN tạo khi:**
1. Có ≥2 implementations (MySQL, PostgreSQL, MongoDB)
2. Cần mock để test (Repository, External API clients)
3. Logic có thể thay đổi theo môi trường (dev/staging/prod)
4. Tích hợp hệ thống ngoài (Payment gateway, Email service)

✋ **KHÔNG CẦN khi:**
1. Chỉ có 1 implementation và không bao giờ thay đổi
2. Internal utilities đơn giản (DateFormatter, StringUtils)
3. Tạo interface chỉ để "tuân thủ best practice" → over-engineering

---

## 4. LIFETIME/SCOPE (Singleton, Scoped, Transient)

Trong enterprise apps (đặc biệt web apps), **lifetime** của dependencies rất quan trọng.

### 4.1. Singleton (1 instance cho toàn bộ app)

```java
// Chỉ tạo 1 instance, dùng chung cho tất cả requests
@Singleton  // hoặc @ApplicationScoped (Java EE/Jakarta)
public class ConfigService {
    private Map<String, String> config;
    
    public ConfigService() {
        // Load config 1 lần duy nhất
        this.config = loadConfigFromFile();
    }
    
    public String get(String key) {
        return config.get(key);
    }
}
```

**Khi nào dùng:**
- ✓ Configuration (database URL, API keys)
- ✓ Caching services
- ✓ Connection pools
- ✓ Stateless services không có state riêng cho từng request

**Lưu ý:** 
- ⚠️ Phải **thread-safe** vì nhiều threads dùng chung
- ⚠️ Không lưu state riêng của request (user ID, session data)

---

### 4.2. Scoped (1 instance cho 1 request/transaction)

```java
// Mỗi HTTP request có 1 instance mới
@RequestScoped  // hoặc @Scoped (Spring)
public class CurrentUserContext {
    private User currentUser;
    
    public void setUser(User user) {
        this.currentUser = user;
    }
    
    public User getUser() {
        return currentUser;
    }
}
```

**Khi nào dùng:**
- ✓ User context (current user, session)
- ✓ Database transaction (1 transaction per request)
- ✓ Request-specific data

**Lưu ý:**
- ⚠️ Không dùng cho long-running background tasks
- ⚠️ Web framework phải hỗ trợ scope này

---

### 4.3. Transient (Mỗi lần inject = 1 instance mới)

```java
// Mỗi lần inject tạo instance mới
@Transient  // hoặc @Prototype (Spring)
public class OrderValidator {
    private List<String> errors = new ArrayList<>();
    
    public boolean validate(Order order) {
        errors.clear();
        
        if (order.getItems().isEmpty()) {
            errors.add("Order must have items");
        }
        
        return errors.isEmpty();
    }
    
    public List<String> getErrors() {
        return errors;
    }
}
```

**Khi nào dùng:**
- ✓ Stateful objects (có state riêng mỗi lần dùng)
- ✓ Objects giữ data tạm thời
- ✓ Validators, builders

**Lưu ý:**
- ⚠️ Tốn memory nếu tạo quá nhiều instances
- ⚠️ Cân nhắc pooling nếu object nặng

---

### So sánh Lifetime

| Lifetime | Khi nào tạo | Khi nào destroy | Use cases |
|----------|-------------|-----------------|-----------|
| **Singleton** | Lúc app start | Lúc app shutdown | Config, Cache, Connection Pool |
| **Scoped** | Đầu request/transaction | Cuối request/transaction | User Context, DB Transaction |
| **Transient** | Mỗi lần inject | Khi không còn reference | Validators, Temporary data |

---

## 5. ANTI-PATTERNS CẦN TRÁNH

### ❌ Anti-pattern 1: Service Locator

```java
// BAD: Service Locator pattern
public class OrderService {
    public void createOrder(Order order) {
        // Lấy dependency từ "global registry"
        OrderRepository repo = ServiceLocator.get(OrderRepository.class);
        EmailService email = ServiceLocator.get(EmailService.class);
        
        repo.save(order);
        email.send(order.getCustomerEmail(), "Order created!");
    }
}

// Service Locator
public class ServiceLocator {
    private static Map<Class<?>, Object> services = new HashMap<>();
    
    public static <T> T get(Class<T> type) {
        return (T) services.get(type);
    }
    
    public static <T> void register(Class<T> type, T instance) {
        services.put(type, instance);
    }
}
```

**Vấn đề:**
- ✗ **Hidden dependencies:** Không rõ class cần gì (phải đọc code)
- ✗ **Khó test:** Phải setup ServiceLocator trước khi test
- ✗ **Runtime errors:** Nếu quên register service → crash khi chạy
- ✗ **Global state:** Khó quản lý, dễ race conditions

**Giải pháp:** Dùng Constructor Injection thay thế.

---

### ❌ Anti-pattern 2: `new` lung tung trong business code

```java
// BAD: Tạo dependencies bên trong method
public class OrderService {
    public void createOrder(Order order) {
        OrderRepository repo = new MySQLOrderRepository();  // ← BAD
        repo.save(order);
        
        EmailService email = new GmailEmailService();  // ← BAD
        email.send(order.getCustomerEmail(), "Order created!");
    }
}
```

**Vấn đề:**
- ✗ Không thể test (không thể mock)
- ✗ Mỗi lần gọi method tạo object mới (waste memory)
- ✗ Gắn chặt với implementation cụ thể

**Giải pháp:** Inject dependencies qua constructor.

---

### ❌ Anti-pattern 3: Circular Dependency

```java
// BAD: A phụ thuộc B, B phụ thuộc A
public class OrderService {
    private PaymentService paymentService;
    
    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}

public class PaymentService {
    private OrderService orderService;
    
    public PaymentService(OrderService orderService) {  // ← Circular!
        this.orderService = orderService;
    }
}
```

**Vấn đề:**
- ✗ Không thể khởi tạo (chicken-egg problem)
- ✗ Sign của thiết kế tồi

**Giải pháp:**
1. **Refactor:** Tách logic chung ra service thứ 3
2. **Event-driven:** A publish event, B subscribe
3. **Interface segregation:** Tách interface nhỏ hơn

```java
// GOOD: Tách logic chung
public class OrderProcessor {
    private OrderRepository orderRepo;
    private PaymentRepository paymentRepo;
    
    public void processOrder(Order order, Payment payment) {
        orderRepo.save(order);
        paymentRepo.save(payment);
    }
}

public class OrderService {
    private OrderProcessor processor;
    // Không còn phụ thuộc PaymentService
}

public class PaymentService {
    private OrderProcessor processor;
    // Không còn phụ thuộc OrderService
}
```

---

### ❌ Anti-pattern 4: Too Many Dependencies (Constructor với >5 params)

```java
// BAD: Constructor quá nhiều parameters
public class OrderService {
    public OrderService(
        OrderRepository repo,
        EmailService email,
        SmsService sms,
        InventoryService inventory,
        ShippingService shipping,
        AnalyticsService analytics,
        LoggingService logging,
        CacheService cache
    ) {
        // 8 dependencies - quá nhiều!
    }
}
```

**Vấn đề:**
- ✗ **Vi phạm Single Responsibility:** Class làm quá nhiều việc
- ✗ **Khó test:** Phải mock 8 dependencies
- ✗ **Khó maintain:** Thêm dependency → sửa nhiều chỗ

**Giải pháp:**
1. **Refactor:** Tách class lớn thành nhiều class nhỏ
2. **Facade:** Gom dependencies liên quan vào 1 facade
3. **Events:** Dùng events thay vì inject trực tiếp

```java
// GOOD: Tách thành nhiều services nhỏ
public class OrderCreationService {
    private OrderRepository repo;
    private InventoryService inventory;
    
    // Chỉ lo tạo order
}

public class OrderNotificationService {
    private EmailService email;
    private SmsService sms;
    
    // Chỉ lo notification
}

public class OrderAnalyticsService {
    private AnalyticsService analytics;
    private LoggingService logging;
    
    // Chỉ lo analytics
}

// Hoặc dùng Events
public class OrderService {
    private OrderRepository repo;
    private EventPublisher events;  // Chỉ 2 dependencies!
    
    public void createOrder(Order order) {
        repo.save(order);
        events.publish(new OrderCreatedEvent(order));
        // Các service khác subscribe event này
    }
}
```

---

## 6. DI GIÚP TEST NHƯ THẾ NÀO?

### Ví dụ: Test OrderService với Mock Dependencies

**Code production:**
```java
public interface OrderRepository {
    void save(Order order);
    Order findById(String id);
}

public interface EmailService {
    void send(String to, String subject, String body);
}

public class OrderService {
    private final OrderRepository repo;
    private final EmailService email;
    
    public OrderService(OrderRepository repo, EmailService email) {
        this.repo = repo;
        this.email = email;
    }
    
    public void createOrder(Order order) {
        if (order.getItems().isEmpty()) {
            throw new IllegalArgumentException("Order must have items");
        }
        
        repo.save(order);
        email.send(
            order.getCustomerEmail(),
            "Order Confirmation",
            "Your order " + order.getId() + " is confirmed!"
        );
    }
}
```

**Test với mocks (Mockito):**
```java
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

public class OrderServiceTest {
    
    @Test
    public void testCreateOrder_Success() {
        // Arrange: Tạo mocks
        OrderRepository mockRepo = mock(OrderRepository.class);
        EmailService mockEmail = mock(EmailService.class);
        
        OrderService service = new OrderService(mockRepo, mockEmail);
        
        Order order = new Order("ORD-123", "customer@email.com");
        order.addItem(new OrderItem("Product A", 100));
        
        // Act
        service.createOrder(order);
        
        // Assert: Verify interactions
        verify(mockRepo, times(1)).save(order);
        verify(mockEmail, times(1)).send(
            eq("customer@email.com"),
            eq("Order Confirmation"),
            contains("ORD-123")
        );
    }
    
    @Test
    public void testCreateOrder_EmptyItems_ThrowsException() {
        OrderRepository mockRepo = mock(OrderRepository.class);
        EmailService mockEmail = mock(EmailService.class);
        
        OrderService service = new OrderService(mockRepo, mockEmail);
        
        Order emptyOrder = new Order("ORD-456", "customer@email.com");
        // Không add items
        
        // Assert: Expect exception
        assertThrows(IllegalArgumentException.class, () -> {
            service.createOrder(emptyOrder);
        });
        
        // Verify không gọi save/send khi có lỗi
        verify(mockRepo, never()).save(any());
        verify(mockEmail, never()).send(any(), any(), any());
    }
    
    @Test
    public void testCreateOrder_EmailServiceFails_OrderStillSaved() {
        OrderRepository mockRepo = mock(OrderRepository.class);
        EmailService mockEmail = mock(EmailService.class);
        
        // Setup: Email service throw exception
        doThrow(new RuntimeException("Email server down"))
            .when(mockEmail).send(any(), any(), any());
        
        OrderService service = new OrderService(mockRepo, mockEmail);
        
        Order order = new Order("ORD-789", "customer@email.com");
        order.addItem(new OrderItem("Product B", 200));
        
        // Act & Assert
        assertThrows(RuntimeException.class, () -> {
            service.createOrder(order);
        });
        
        // Verify order vẫn được save trước khi email fail
        verify(mockRepo, times(1)).save(order);
    }
}
```

**Lợi ích:**
- ✓ **Không cần DB thật:** Mock repository
- ✓ **Không gửi email thật:** Mock email service
- ✓ **Test nhanh:** Không I/O, chỉ test logic
- ✓ **Test edge cases:** Dễ dàng setup scenarios (email fail, DB timeout...)
- ✓ **Isolated:** Test từng class độc lập

---

### Test với In-Memory Implementation (Alternative to Mocks)

```java
// In-memory implementation cho testing
public class InMemoryOrderRepository implements OrderRepository {
    private Map<String, Order> storage = new HashMap<>();
    
    @Override
    public void save(Order order) {
        storage.put(order.getId(), order);
    }
    
    @Override
    public Order findById(String id) {
        return storage.get(id);
    }
    
    // Helper cho testing
    public boolean contains(String id) {
        return storage.containsKey(id);
    }
}

// Test
@Test
public void testCreateOrder_WithInMemoryRepo() {
    InMemoryOrderRepository repo = new InMemoryOrderRepository();
    EmailService mockEmail = mock(EmailService.class);
    
    OrderService service = new OrderService(repo, mockEmail);
    
    Order order = new Order("ORD-999", "test@email.com");
    order.addItem(new OrderItem("Product C", 300));
    
    service.createOrder(order);
    
    // Assert order đã được save
    assertTrue(repo.contains("ORD-999"));
    assertEquals(order, repo.findById("ORD-999"));
}
```

---

## 7. DI CONTAINER/FRAMEWORK (Spring, Guice, CDI...)

Trong enterprise apps thực tế, thường dùng **DI Container** để tự động quản lý dependencies.

### Ví dụ: Spring Framework

```java
// 1. Định nghĩa interfaces
public interface OrderRepository {
    void save(Order order);
}

public interface EmailService {
    void send(String to, String subject, String body);
}

// 2. Implementations với @Component
@Repository  // Spring annotation
public class JpaOrderRepository implements OrderRepository {
    @PersistenceContext
    private EntityManager em;
    
    @Override
    public void save(Order order) {
        em.persist(order);
    }
}

@Service
public class SmtpEmailService implements EmailService {
    @Value("${email.smtp.host}")
    private String smtpHost;
    
    @Override
    public void send(String to, String subject, String body) {
        // SMTP implementation
    }
}

// 3. Service với constructor injection
@Service
public class OrderService {
    private final OrderRepository repo;
    private final EmailService email;
    
    // Spring tự động inject (không cần @Autowired từ Spring 4.3+)
    public OrderService(OrderRepository repo, EmailService email) {
        this.repo = repo;
        this.email = email;
    }
    
    public void createOrder(Order order) {
        repo.save(order);
        email.send(order.getCustomerEmail(), "Order Confirmation", "...");
    }
}

// 4. Controller
@RestController
@RequestMapping("/orders")
public class OrderController {
    private final OrderService orderService;
    
    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }
    
    @PostMapping
    public ResponseEntity<String> createOrder(@RequestBody Order order) {
        orderService.createOrder(order);
        return ResponseEntity.ok("Order created!");
    }
}

// Spring tự động:
// - Tạo instances của JpaOrderRepository, SmtpEmailService
// - Inject vào OrderService constructor
// - Inject OrderService vào OrderController
// - Quản lý lifetime (singleton by default)
```

**Lợi ích DI Container:**
- ✓ **Auto-wiring:** Tự động inject dependencies
- ✓ **Lifecycle management:** Quản lý singleton/scope/transient
- ✓ **Configuration:** Dễ config qua annotations hoặc XML/Java config
- ✓ **AOP support:** Dễ thêm cross-cutting concerns (logging, transactions...)

**Lưu ý:**
- ⚠️ Đừng lạm dụng framework magic → code khó hiểu
- ⚠️ Hiểu DI concept trước khi dùng framework
- ⚠️ Constructor injection > Field injection (kể cả với Spring)

---

## 8. BÀI TẬP THỰC HÀNH

### Bài 1: REFACTOR SANG DI

**Code hiện tại (không DI):**
```java
public class UserService {
    public User register(String email, String password) {
        // Validate
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email");
        }
        
        // Hash password
        PasswordHasher hasher = new BCryptPasswordHasher();
        String hashedPassword = hasher.hash(password);
        
        // Save to DB
        UserRepository repo = new MySQLUserRepository();
        User user = new User(email, hashedPassword);
        repo.save(user);
        
        // Send welcome email
        EmailService emailService = new SendGridEmailService();
        emailService.send(email, "Welcome!", "Thanks for registering!");
        
        return user;
    }
}
```

**Câu hỏi:**
1. Liệt kê tất cả vấn đề của code này
2. Refactor sang DI với constructor injection
3. Tạo interfaces phù hợp
4. Viết unit test cho method `register()` với mocks

---

### Bài 2: CHỌN LIFETIME PHÙ HỢP

**Cho các services sau, hãy chọn lifetime phù hợp và giải thích:**

```java
// Service 1
public class DatabaseConnectionPool {
    private List<Connection> connections = new ArrayList<>();
    
    public DatabaseConnectionPool() {
        // Khởi tạo 10 connections
        for (int i = 0; i < 10; i++) {
            connections.add(createConnection());
        }
    }
    
    public Connection getConnection() {
        // Return available connection
    }
}

// Service 2
public class CurrentUserProvider {
    private User currentUser;
    
    public void setUser(User user) {
        this.currentUser = user;
    }
    
    public User getUser() {
        return currentUser;
    }
}

// Service 3
public class OrderValidator {
    private List<String> validationErrors = new ArrayList<>();
    
    public boolean validate(Order order) {
        validationErrors.clear();
        // validation logic
        return validationErrors.isEmpty();
    }
    
    public List<String> getErrors() {
        return validationErrors;
    }
}

// Service 4
public class EmailTemplateEngine {
    private Map<String, String> templateCache = new HashMap<>();
    
    public String render(String templateName, Map<String, Object> data) {
        String template = templateCache.get(templateName);
        if (template == null) {
            template = loadTemplate(templateName);
            templateCache.put(templateName, template);
        }
        return processTemplate(template, data);
    }
}
```

**Câu hỏi:**
- Service 1 nên là: Singleton / Scoped / Transient? Tại sao?
- Service 2 nên là: Singleton / Scoped / Transient? Tại sao?
- Service 3 nên là: Singleton / Scoped / Transient? Tại sao?
- Service 4 nên là: Singleton / Scoped / Transient? Tại sao?

---

### Bài 3: FIX CIRCULAR DEPENDENCY

**Code hiện tại:**
```java
public class ProductService {
    private CategoryService categoryService;
    
    public ProductService(CategoryService categoryService) {
        this.categoryService = categoryService;
    }
    
    public List<Product> getProductsByCategory(String categoryId) {
        Category category = categoryService.findById(categoryId);
        return category.getProducts();
    }
}

public class CategoryService {
    private ProductService productService;
    
    public CategoryService(ProductService productService) {
        this.productService = productService;
    }
    
    public List<Category> getCategoriesWithProducts() {
        List<Category> categories = findAll();
        for (Category category : categories) {
            List<Product> products = productService.getProductsByCategory(category.getId());
            category.setProducts(products);
        }
        return categories;
    }
}
```

**Câu hỏi:**
1. Tại sao code này có circular dependency?
2. Đề xuất ít nhất 2 cách refactor để giải quyết
3. Implement cách refactor tốt nhất theo bạn

---

### Bài 4: ANTI-PATTERN IDENTIFICATION

**Đoạn code sau có những anti-patterns nào? Sửa lại.**

```java
public class ReportService {
    
    public void generateReport(String reportType) {
        // Anti-pattern 1: Service Locator
        ReportRepository repo = ServiceLocator.get(ReportRepository.class);
        
        // Anti-pattern 2: new trong method
        ReportGenerator generator;
        if (reportType.equals("PDF")) {
            generator = new PdfReportGenerator();
        } else if (reportType.equals("EXCEL")) {
            generator = new ExcelReportGenerator();
        } else {
            generator = new CsvReportGenerator();
        }
        
        Data data = repo.fetchData();
        generator.generate(data);
        
        // Anti-pattern 3: static method call
        EmailSender.send("admin@company.com", "Report generated");
    }
}
```

**Câu hỏi:**
1. Liệt kê tất cả anti-patterns
2. Refactor sang DI đúng cách
3. Tạo interfaces cần thiết

---

## 9. CHECKLIST TỰ ĐÁNH GIÁ

Sau Task 2, bạn check xem đã đạt được chưa:

- [ ] Hiểu DI là gì và tại sao quan trọng
- [ ] Biết 3 cách injection và ưu tiên Constructor Injection
- [ ] Biết tạo interface để tách abstraction khỏi implementation
- [ ] Hiểu 3 loại lifetime: Singleton, Scoped, Transient
- [ ] Nhận diện được 4 anti-patterns phổ biến về DI
- [ ] Biết cách viết unit test với mock dependencies
- [ ] Hiểu cơ bản về DI Container (Spring/Guice...)
- [ ] Có thể refactor code không DI → có DI

---

## 10. TÀI LIỆU THAM KHẢO

**Đọc thêm:**
- Martin Fowler - "Inversion of Control Containers and the Dependency Injection pattern"
- Mark Seemann - "Dependency Injection in .NET" (áp dụng được cho Java)
- Spring Framework Documentation - "Core: The IoC Container"

**Video hay:**
- "SOLID Principles" - Uncle Bob (phần Dependency Inversion)
- "Dependency Injection Demystified" - James Shore

---

## KẾT LUẬN TASK 2

**Nhớ kỹ:**
1. **Constructor Injection first:** Default choice cho dependencies
2. **Depend on abstractions:** Interface > Concrete classes
3. **One responsibility per class:** Nếu có >5 dependencies → refactor
4. **DI enables testing:** Mock dependencies dễ dàng
5. **Know your lifetime:** Singleton cho stateless, Scoped cho request, Transient cho stateful

**Câu nói hay:**
> "Don't call us, we'll call you" - Hollywood Principle (IoC/DI)
>
> "New is glue" - Dependencies tạo bằng `new` là coupling cứng nhắc

---

**Next:** Task 3 - Factory/Factory Method - tạo objects theo config/type!
