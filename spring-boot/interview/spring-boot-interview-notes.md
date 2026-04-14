# Spring Boot – Kiến thức phỏng vấn tổng hợp

## 1) Spring Boot là gì

Spring Boot là framework xây trên Spring Framework, giúp tạo ứng dụng chạy độc lập, cấu hình tối thiểu, có embedded server, starter dependencies, auto-configuration, actuator, và hỗ trợ production tốt.

Cách trả lời phỏng vấn ngắn:
> Spring Boot là nền tảng giúp xây dựng ứng dụng Spring nhanh hơn nhờ auto-configuration, starter dependencies, embedded server, externalized configuration, và nhiều tính năng production-ready như Actuator.

---

## 2) Spring và Spring Boot khác nhau thế nào

### Spring Framework
Là framework nền tảng, cung cấp IoC, DI, AOP, transaction, MVC, data access, v.v.

### Spring Boot
Là lớp tăng tốc trên Spring:
- tự cấu hình nhiều thứ
- gom dependency theo starter
- nhúng server như Tomcat/Jetty
- chạy nhanh bằng `java -jar`
- có Actuator để monitoring/health

Câu trả lời đẹp:
> Spring là framework gốc, còn Spring Boot giúp giảm cấu hình thủ công, cung cấp auto-configuration, starter, embedded server và các tính năng production-ready để build app nhanh hơn.

---

## 3) `@SpringBootApplication` là gì

`@SpringBootApplication` là annotation rất hay bị hỏi.

Bạn có thể hiểu thực tế nó bao gồm ý tưởng của:
- cấu hình Spring
- component scanning
- auto-configuration

Ví dụ:
```java
@SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```

Câu trả lời ngắn:
> `@SpringBootApplication` là annotation tiện lợi để khởi động ứng dụng Spring Boot, thường dùng làm entry point và bật component scan cùng auto-configuration.

---

## 4) Auto-configuration là gì

Đây là câu cực hay gặp.

Spring Boot auto-configuration cố gắng tự cấu hình ứng dụng dựa trên dependencies có trên classpath.

### Ví dụ dễ hiểu
- thêm `spring-boot-starter-web` → Boot tự cấu hình web app cơ bản
- thêm JDBC driver + starter JDBC/Data JPA → Boot tự cấu hình datasource ở mức phù hợp nếu đủ thông tin
- thêm actuator → Boot tự cấu hình management endpoints tương ứng

Câu trả lời đẹp:
> Auto-configuration là cơ chế Spring Boot tự tạo cấu hình mặc định dựa trên classpath, bean hiện có, và environment, giúp giảm lượng config thủ công rất nhiều.

---

## 5) Starter là gì

Starter là các dependency “gom gói” để kéo vào bộ thư viện phổ biến cho một use case.

Ví dụ:
- `spring-boot-starter-web`
- `spring-boot-starter-data-jpa`
- `spring-boot-starter-security`
- `spring-boot-starter-test`
- `spring-boot-starter-actuator`

Câu trả lời ngắn:
> Starter là dependency mô tả một nhóm chức năng, giúp kéo đúng bộ thư viện cần thiết mà không phải tự chọn từng artifact riêng lẻ.

---

## 6) Vì sao Spring Boot chạy được ngay

Spring Boot hỗ trợ:
- embedded server
- executable jar
- minimal configuration

Ví dụ:
```bash
java -jar app.jar
```

Câu trả lời:
> Vì Spring Boot đóng gói ứng dụng thành executable jar, thường kèm embedded server, nên không cần cài riêng application server để chạy những ứng dụng phổ biến.

---

## 7) IoC và DI là gì trong Spring Boot

Đây là kiến thức nền nhưng luôn bị hỏi.

### IoC
Inversion of Control nghĩa là framework quản lý object lifecycle thay vì code tự `new` mọi thứ.

### DI
Dependency Injection là cách framework inject dependency vào object.

Ví dụ:
```java
@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```

Câu trả lời đẹp:
> Spring Boot vẫn dựa trên core container của Spring. IoC là framework quản lý bean, còn DI là cơ chế cung cấp dependency cho bean, thường qua constructor injection.

---

## 8) Bean là gì

Bean là object được Spring container quản lý.

Bean thường được tạo từ:
- `@Component`
- `@Service`
- `@Repository`
- `@Controller`
- `@RestController`
- `@Bean` trong class cấu hình

Ví dụ:
```java
@Component
public class EmailSender {
}
```

Hoặc:
```java
@Configuration
public class AppConfig {
    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}
```

---

## 9) `@Component`, `@Service`, `@Repository`, `@Controller` khác gì

Về bản chất đều là stereotype annotation để đăng ký bean, nhưng mục đích ngữ nghĩa khác nhau:

- `@Component`: generic component
- `@Service`: service layer
- `@Repository`: data access layer
- `@Controller`: MVC controller
- `@RestController`: controller trả dữ liệu REST

Câu trả lời hay:
> Chúng đều là stereotype annotation để Spring quản lý bean, nhưng dùng đúng annotation giúp code rõ tầng hơn; riêng `@Repository` còn gắn với ý nghĩa data access và exception translation trong Spring.

---

## 10) Constructor injection vs field injection

Phỏng vấn rất hay hỏi phần này.

### Constructor injection
Ưu điểm:
- dễ test
- dependency rõ ràng
- object immutable hơn với `final`
- fail fast nếu thiếu dependency

### Field injection
- ngắn hơn
- nhưng khó test hơn
- dependency bị ẩn

Câu trả lời đẹp:
> Em ưu tiên constructor injection vì rõ dependency, dễ unit test và phù hợp với thiết kế immutable hơn field injection.

Ví dụ:
```java
@Service
public class OrderService {
    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

---

## 11) `@Configuration` và `@Bean` là gì

`@Configuration` đánh dấu class cấu hình Spring.
`@Bean` đánh dấu method tạo bean.

Ví dụ:
```java
@Configuration
public class AppConfig {
    @Bean
    public Clock systemClock() {
        return Clock.systemUTC();
    }
}
```

Dùng khi:
- cần tạo bean từ class third-party
- cần logic khởi tạo custom
- không muốn hoặc không thể dùng stereotype annotation trực tiếp

---

## 12) `application.properties` và `application.yml`

Spring Boot hỗ trợ externalized configuration.

Bạn có thể cấu hình qua:
- `application.properties`
- `application.yml`
- environment variables
- command line args
- profile-specific config

Ví dụ:
```properties
server.port=8081
spring.datasource.url=jdbc:mysql://localhost:3306/test
```

Hoặc:
```yaml
server:
  port: 8081
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/test
```

Câu trả lời:
> Spring Boot hỗ trợ externalized configuration rất mạnh; em thường dùng `application.yml` nếu cấu trúc config lồng nhau nhiều, còn `properties` nếu dự án muốn đơn giản.

---

## 13) Profile là gì

Profile dùng để tách cấu hình theo môi trường:
- dev
- test
- stg
- prod

Ví dụ:
```properties
spring.profiles.active=dev
```

Hoặc file:
- `application-dev.yml`
- `application-prod.yml`

Câu trả lời ngắn:
> Profile giúp tách cấu hình theo môi trường chạy, tránh hard-code và dễ quản lý behavior khác nhau giữa dev, test, và production.

---

## 14) `@Value` và `@ConfigurationProperties`

Đây là câu hay hỏi.

### `@Value`
Phù hợp khi inject một vài giá trị lẻ.

```java
@Value("${app.name}")
private String appName;
```

### `@ConfigurationProperties`
Phù hợp khi bind một nhóm config có cấu trúc.

```java
@ConfigurationProperties(prefix = "app.mail")
public class MailProperties {
    private String host;
    private int port;
}
```

Câu trả lời đẹp:
> `@Value` phù hợp cho vài property đơn lẻ. `@ConfigurationProperties` tốt hơn khi cấu hình có cấu trúc, dễ maintain, dễ validate và rõ ràng hơn.

---

## 15) Spring Boot starter web dùng gì bên dưới

Với ứng dụng REST MVC phổ biến:
- thường dùng Spring MVC
- embedded Tomcat thường là mặc định trong starter web truyền thống
- nếu dùng reactive thì thường liên quan WebFlux và Reactor Netty hơn

Câu trả lời:
> Với ứng dụng web MVC thông thường, `spring-boot-starter-web` thường kéo Spring MVC và embedded Tomcat; nếu theo reactive stack thì dùng WebFlux thay vì MVC.

---

## 16) `@RestController` khác `@Controller` thế nào

### `@Controller`
Thường dùng cho MVC trả view.

### `@RestController`
Phù hợp cho REST API, trả JSON/XML trực tiếp. Có thể hiểu như `@Controller + @ResponseBody`.

Ví dụ:
```java
@RestController
@RequestMapping("/users")
public class UserController {
    @GetMapping
    public List<String> all() {
        return List.of("A", "B");
    }
}
```

---

## 17) `@RequestParam`, `@PathVariable`, `@RequestBody`

Rất hay hỏi ở phỏng vấn backend.

### `@PathVariable`
Lấy dữ liệu từ path.
```java
@GetMapping("/users/{id}")
public User get(@PathVariable Long id) { ... }
```

### `@RequestParam`
Lấy query parameter.
```java
@GetMapping("/users")
public List<User> search(@RequestParam String keyword) { ... }
```

### `@RequestBody`
Map body JSON vào object.
```java
@PostMapping("/users")
public User create(@RequestBody CreateUserRequest req) { ... }
```

---

## 18) `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`

Đây là shortcut của các annotation request mapping tương ứng theo HTTP method.

Ví dụ:
```java
@GetMapping("/users")
@PostMapping("/users")
@PutMapping("/users/{id}")
@DeleteMapping("/users/{id}")
```

---

## 19) Exception handling trong Spring Boot

Câu rất hay hỏi.

Các cách xử lý:
- `try-catch` trực tiếp
- `@ExceptionHandler`
- `@ControllerAdvice` / `@RestControllerAdvice`
- custom error response

Ví dụ:
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<String> handle(UserNotFoundException ex) {
        return ResponseEntity.status(404).body(ex.getMessage());
    }
}
```

Câu trả lời đẹp:
> Em ưu tiên global exception handling bằng `@RestControllerAdvice` để chuẩn hóa response lỗi và tách riêng error handling khỏi business logic.

---

## 20) Validation trong Spring Boot

Thường dùng:
- `@Valid`
- `@NotNull`
- `@NotBlank`
- `@Size`
- `@Email`

Ví dụ:
```java
public class CreateUserRequest {
    @NotBlank
    private String name;

    @Email
    private String email;
}
```

```java
@PostMapping("/users")
public void create(@Valid @RequestBody CreateUserRequest req) { ... }
```

---

## 21) Spring Boot với database thường đi cùng gì

Rất phổ biến:
- Spring Data JPA
- Hibernate
- JDBC
- transaction management

Câu trả lời:
> Với stack phổ biến, Spring Boot thường đi cùng Spring Data JPA và Hibernate cho ORM, hoặc JDBC/jOOQ nếu muốn kiểm soát SQL nhiều hơn.

---

## 22) `@Transactional` là gì

Đây là câu cực hay hỏi.

`@Transactional` dùng để quản lý transaction declaratively.

Ví dụ:
```java
@Service
public class TransferService {
    @Transactional
    public void transfer(...) {
        // update A
        // update B
    }
}
```

Ý nghĩa:
- nếu thành công → commit
- nếu lỗi phù hợp → rollback

Câu trả lời đẹp:
> `@Transactional` giúp quản lý transaction theo declarative style, giảm code boilerplate commit/rollback thủ công.

Điểm hay bị vặn:
- transaction thường hiệu lực khi method được gọi qua Spring proxy
- self-invocation có thể không đi qua proxy nên dễ không áp dụng như mong đợi

---

## 23) AOP / Proxy trong Spring Boot

Spring Boot dùng nền tảng Spring, nên nhiều tính năng như:
- transaction
- security
- caching
- logging aspect

đều thường dựa trên proxy/AOP.

Câu trả lời ngắn:
> Nhiều tính năng declarative của Spring như `@Transactional`, caching, security method interception thường hoạt động thông qua proxy/AOP.

---

## 24) Actuator là gì

Actuator là một trong những tính năng production-ready tiêu biểu của Spring Boot.

Nó hỗ trợ các endpoint như:
- health
- info
- metrics
- env
- beans
- mappings

tùy cấu hình expose.

Ví dụ dependency:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

Câu trả lời đẹp:
> Actuator cung cấp các endpoint phục vụ monitoring, health check, metrics và quan sát vận hành cho ứng dụng Spring Boot.

---

## 25) Spring Boot DevTools là gì

DevTools giúp cải thiện trải nghiệm phát triển như restart nhanh hơn và một số hỗ trợ dev-time khác trong quá trình local development.

---

## 26) Caching trong Spring Boot

Thường dùng:
- `@EnableCaching`
- `@Cacheable`
- `@CachePut`
- `@CacheEvict`

Ví dụ:
```java
@Cacheable("users")
public User getUser(Long id) { ... }
```

Câu trả lời:
> Spring Boot tích hợp dễ với Spring Cache abstraction; em chỉ dùng cache khi đọc nhiều, dữ liệu ít đổi, và có chiến lược invalidation rõ ràng.

---

## 27) Security trong Spring Boot

Những ý hay bị hỏi:
- Spring Security để authentication/authorization
- có thể bảo vệ endpoint REST
- có thể cấu hình filter chain
- thường kết hợp JWT/OAuth2 trong dự án API hiện đại

---

## 28) Testing trong Spring Boot

Rất hay hỏi.

Các kiểu test:
- unit test
- integration test
- web layer test
- data layer test

Hay gặp:
- `@SpringBootTest`
- `@WebMvcTest`
- `@DataJpaTest`
- `MockMvc`

Câu trả lời đẹp:
> Em không dùng `@SpringBootTest` cho mọi thứ vì nó nặng; em chọn slice test như `@WebMvcTest` hay `@DataJpaTest` khi phù hợp để test nhanh và cô lập hơn.

---

## 29) Embedded server là gì

Ý nghĩa:
- app web có thể chạy tự chứa
- không cần deploy lên external Tomcat trong nhiều trường hợp
- dễ containerize hơn

---

## 30) Spring Boot có microservice không

Spring Boot không đồng nghĩa microservice, nhưng nó rất hay được dùng để xây microservice vì:
- startup nhanh
- config đơn giản
- đóng gói dễ
- actuator tốt
- ecosystem mạnh

Câu trả lời:
> Spring Boot không bắt buộc là microservice framework, nhưng nó rất phù hợp để xây microservice nhờ khả năng auto-configuration, embedded runtime, actuator, và tích hợp tốt với hệ sinh thái Spring.

---

## 31) Các câu hỏi hay gặp và cách trả lời

### Spring Boot là gì
> Spring Boot là nền tảng giúp xây ứng dụng Spring nhanh hơn nhờ auto-configuration, starter dependencies, executable jar, embedded server và các tính năng production-ready.

### Auto-configuration là gì
> Là cơ chế tự cấu hình ứng dụng dựa trên dependency có trên classpath và bean/config hiện có, giúp giảm config thủ công.

### Starter là gì
> Là nhóm dependency được đóng gói theo use case như web, data-jpa, security, actuator để tránh phải kéo tay từng thư viện.

### Vì sao constructor injection tốt hơn
> Vì dependency rõ ràng, dễ test, dễ dùng `final`, và tránh field injection khó kiểm soát.

### `@SpringBootApplication` làm gì
> Nó là entry-point phổ biến của app Boot và bật cơ chế cấu hình ứng dụng, bao gồm auto-configuration.

### `@RestController` khác `@Controller` thế nào
> `@RestController` phù hợp cho REST API và trả body trực tiếp; `@Controller` thường dùng cho MVC/view rendering.

### Actuator là gì
> Là bộ endpoint phục vụ monitoring, health, metrics, info và vận hành production.

### `@Transactional` là gì
> Là cách khai báo transaction bằng annotation thay vì commit/rollback thủ công.

---

## 32) Bẫy phỏng vấn hay gặp

- nhầm Spring với Spring Boot
- tưởng Boot “không cần Spring”
- không hiểu auto-configuration hoạt động dựa trên classpath
- lạm dụng field injection
- dùng `@SpringBootTest` cho mọi test
- không phân biệt `@Controller` và `@RestController`
- nghĩ `application.yml` luôn tốt hơn `properties`
- không hiểu profile
- không biết actuator dùng làm gì
- quên self-invocation issue của `@Transactional`

---

## 33) Mẫu trả lời 1 phút

Nếu nhà tuyển dụng hỏi:
**“Em hãy trình bày hiểu biết về Spring Boot.”**

Bạn có thể trả lời như sau:

> Spring Boot là nền tảng xây trên Spring Framework để giúp tạo ứng dụng nhanh hơn với cấu hình tối thiểu. Nó cung cấp auto-configuration dựa trên classpath, starter dependencies cho từng use case như web, data, security, embedded server để chạy dạng executable jar, và các tính năng production-ready như Actuator. Trong thực tế em thường dùng Spring Boot để xây REST API, quản lý bean qua DI, tách config theo profile, xử lý transaction bằng `@Transactional`, validate request bằng Bean Validation, và theo dõi ứng dụng qua actuator. Khi phỏng vấn hoặc làm thực tế, em chú ý nhất các phần như auto-configuration, bean lifecycle, constructor injection, externalized configuration, exception handling, testing, và tích hợp với data layer như Spring Data JPA/Hibernate.

---

## 34) Cách học để đi phỏng vấn

Bạn nên ôn theo thứ tự này:

### Mức 1
- Spring Boot là gì
- Spring vs Spring Boot
- `@SpringBootApplication`
- auto-configuration
- starter
- bean, DI, IoC

### Mức 2
- config, profile, `@Value`, `@ConfigurationProperties`
- web annotations
- exception handling
- validation
- `@Transactional`
- actuator

### Mức 3
- AOP/proxy
- test slices
- security cơ bản
- caching
- self-invocation
- tối ưu design/config production
