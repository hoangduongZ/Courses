# Spring Boot Junior -> Middle Interview (Task-based Learning Plan)

> Mục tiêu: xây nền tảng vững về Spring Boot (3.x) cho phỏng vấn Java Backend từ Junior đến Middle, tập trung vào tư duy thiết kế, vận hành và tối ưu.

---

## Cách học đề xuất
- Mỗi task học theo thứ tự: concept -> ví dụ code ngắn -> câu hỏi phỏng vấn -> bài tập tự code.
- Ưu tiên giải thích trade-off (vì sao chọn cách này, khi nào không nên dùng).
- Sau mỗi 3 task, tự mock interview 20-30 phút.
- Mỗi task nên có 1 mini project nhỏ để tổng hợp.

---

## COMMON - Core Spring Boot (phỏng vấn hỏi nhiều)

## TASK 01 - Spring Boot fundamentals, auto-configuration, starter
- Mục tiêu: hiểu cách Spring Boot khởi tạo ứng dụng, auto-config hoạt động ra sao.
- File: task-01-spring-boot-fundamentals-autoconfig-starter.md

## TASK 02 - IoC, DI, bean lifecycle, scopes
- Mục tiêu: nắm chắc @Component, @Service, @Repository, @Configuration và lifecycle bean.
- File: task-02-ioc-di-bean-lifecycle-scopes.md

## TASK 03 - Configuration management (application.yml, profiles, @ConfigurationProperties)
- Mục tiêu: quản lý cấu hình theo môi trường an toàn, dễ maintain.
- File: task-03-configuration-profiles-properties.md

## TASK 04 - REST API design with Spring MVC
- Mục tiêu: xây dựng API đúng chuẩn, versioning có chiến lược, validation rõ ràng.
- File: task-04-rest-api-design-spring-mvc.md

## TASK 05 - Validation, exception handling, response standardization
- Mục tiêu: dùng Bean Validation, @ControllerAdvice, trả lời lỗi nhất quán.
- File: task-05-validation-exception-response-standard.md

## TASK 06 - Data access with Spring Data JPA
- Mục tiêu: viết repository đúng, hiểu entity mapping, transaction boundary.
- File: task-06-spring-data-jpa-core.md

## TASK 07 - Transaction management and consistency
- Mục tiêu: hiểu @Transactional, propagation/isolation, pitfall rollback.
- File: task-07-transaction-management-consistency.md

## TASK 08 - Testing (unit, slice, integration with Testcontainers)
- Mục tiêu: biết chọn đúng cấp test, test nhanh nhưng vẫn tin cậy.
- File: task-08-testing-unit-slice-integration.md

## TASK 09 - Security basics with Spring Security
- Mục tiêu: hiểu authentication/authorization, JWT/session, endpoint protection.
- File: task-09-spring-security-basics.md

## TASK 10 - Observability: logging, actuator, metrics, tracing basics
- Mục tiêu: debug và monitor được ứng dụng khi chạy thật.
- File: task-10-observability-logging-actuator-metrics.md

---

## MIDDLE-LEVEL BOOSTER - Nâng cấp tư duy phỏng vấn

## TASK 11 - Performance and scalability mindset
- Mục tiêu: xử lý N+1, caching, connection pool, thread pool, bottleneck phân tích.
- File: task-11-performance-scalability-mindset.md

## TASK 12 - Event-driven patterns and async processing
- Mục tiêu: sử dụng @Async, queue/event, eventual consistency đúng ngữ cảnh.
- File: task-12-event-driven-async-processing.md

## TASK 13 - Resilience patterns for distributed systems
- Mục tiêu: timeout, retry, circuit breaker, idempotency với tính ổn định cao.
- File: task-13-resilience-patterns-distributed-systems.md

## TASK 14 - Deployment and production readiness
- Mục tiêu: dockerize, config production, health checks, graceful shutdown.
- File: task-14-deployment-production-readiness.md

## TASK 15 - System design mini checklist (Junior -> Middle)
- Mục tiêu: trả lời bài toán service design từ API, DB, cache đến monitoring.
- File: task-15-system-design-mini-checklist.md

---

## Đề xuất mini project theo giai đoạn
- Stage 1 (Task 1-5): CRUD API cho Product + validation + exception standard.
- Stage 2 (Task 6-10): bổ sung JPA, security, test đầy đủ, actuator.
- Stage 3 (Task 11-15): thêm cache, async/event, resilience và script deploy.

---

## Definition of Done
- Bạn giải thích được mỗi topic bằng ví dụ ngắn 3-5 phút.
- Bạn tự code được mini bài tập không cần nhìn tài liệu.
- Bạn trả lời được: khi nào dùng, khi nào không dùng, pitfall và cách debug.
- Bạn vẽ được luồng request end-to-end: controller -> service -> repository -> db.
