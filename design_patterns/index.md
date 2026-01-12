# Enterprise Design Patterns “không thừa” — Task-based Learning Plan (Coding thường dùng)

> Mục tiêu: học **đủ** những pattern hay gặp trong dự án enterprise (Java/C#/TS/PHP đều áp dụng được)
> - Viết code dễ mở rộng, dễ test, dễ maintain
> - Tránh “over-engineering”: chỉ chọn pattern có ROI cao khi đi làm
>
> Ghi nhớ: Pattern = “giải pháp có tên” cho vấn đề lặp lại, **không phải** mục tiêu để nhồi nhét.

---

## Task 1 — Nắm mindset: Khi nào cần pattern, khi nào không
**Mục đích:** Tránh lạm dụng pattern làm code phức tạp.

**Keypoint cần học**
- Dấu hiệu cần pattern: code lặp, nhiều if-else theo loại, khó test, phụ thuộc chặt, thay đổi thường xuyên
- Dấu hiệu không cần: logic nhỏ, thay đổi ít, team nhỏ, deadline gấp
- 3 tiêu chí enterprise: maintainability, testability, extensibility
- “Prefer composition over inheritance”

---

## Task 2 — Dependency Injection (DI) (pattern/technique cốt lõi enterprise)
**Mục đích:** Tách phụ thuộc để dễ test, dễ thay thế implementation.

**Keypoint cần học**
- Constructor injection (ưu tiên)
- Interface/abstraction cho service/repo/client
- Lifetime (singleton/scoped/transient) (đặc biệt C#)
- Anti-pattern: Service Locator, new lung tung trong business code
- DI giúp test: mock/stub dependencies

---

## Task 3 — Factory / Factory Method (tạo object theo config/type)
**Mục đích:** Tránh `new` rải rác + if-else chọn class theo loại.

**Keypoint cần học**
- Khi nào dùng: chọn implementation theo `type`, environment, config
- Factory trả về interface (polymorphism)
- Factory Method vs Simple Factory (thực dụng)
- Anti-pattern: switch-case khổng lồ không gom lại

---

## Task 4 — Strategy (thay thế if-else theo “rule/thuật toán”)
**Mục đích:** Gom các thuật toán/rule thay đổi thường xuyên thành các class/func riêng.

**Keypoint cần học**
- Khi nào dùng: pricing rules, validation rules, routing logic, discount, scoring
- Interface `Strategy` + nhiều implementation
- Chọn strategy bằng factory/map
- Test từng strategy độc lập

---

## Task 5 — Template Method (khung xử lý cố định + điểm mở rộng)
**Mục đích:** Chuẩn hóa flow xử lý nhưng vẫn cho phép custom theo từng case.

**Keypoint cần học**
- Khi nào dùng: batch/job pipeline, import/export flow, handler flow
- Base class định nghĩa skeleton: `validate -> process -> persist -> notify`
- Hook methods để override từng bước
- Cẩn thận lạm dụng inheritance (chỉ dùng khi flow thực sự ổn định)

---

## Task 6 — Adapter (tích hợp hệ thống ngoài / legacy)
**Mục đích:** Tích hợp API/SDK khác nhau mà không làm bẩn domain code.

**Keypoint cần học**
- Khi nào dùng: payment gateway, external CRM, email/SMS providers, legacy libs
- Adapter chuyển interface “A” → “B”
- Domain code phụ thuộc interface nội bộ, không phụ thuộc SDK ngoài
- Dễ mock external trong test

---

## Task 7 — Facade (đơn giản hóa API phức tạp)
**Mục đích:** Tạo lớp “cổng” để code gọi đơn giản, giảm coupling.

**Keypoint cần học**
- Khi nào dùng: nhiều service phải phối hợp (payment + inventory + shipping)
- Facade orchestration, nhưng không chứa business rule lõi quá nhiều
- Giúp giảm “đi xuyên tầng” (controller gọi 5 service lẻ)

---

## Task 8 — Repository (tách data access khỏi business)
**Mục đích:** Domain/service không dính chi tiết DB/ORM/SQL.

**Keypoint cần học**
- Repository interface: `findById`, `save`, `search`
- Mapping entity ↔ domain model (khi cần)
- Tránh repository “query builder lộ thiên” trong service
- Anti-pattern: repository quá chung chung, trả “mọi thứ”

---

## Task 9 — Unit of Work / Transaction Script (thực dụng cho DB transaction)
**Mục đích:** Quản lý transaction rõ ràng, tránh commit/rollback rải rác.

**Keypoint cần học**
- Unit of Work: gom các thay đổi rồi commit 1 lần (ORM hay có sẵn)
- Transaction Script: 1 use-case = 1 transaction rõ ràng
- Khi nào cần explicit transaction boundary
- Idempotency & retry awareness (enterprise)

---

## Task 10 — DTO + Mapper (boundary pattern)
**Mục đích:** Tách model nội bộ khỏi model API/UI/DB để tránh “leak”.

**Keypoint cần học**
- Request/Response DTO cho API
- Mapping layer (manual hoặc mapper tool)
- Không expose entity/ORM model ra ngoài
- Versioning & backward compatibility cho DTO

---

## Task 11 — Observer / Pub-Sub (Events) (decouple & async)
**Mục đích:** Tách “hậu xử lý” ra khỏi flow chính; mở rộng mà không sửa core.

**Keypoint cần học**
- Domain events: `OrderPlaced`, `UserRegistered`
- Sync events (in-process) vs async events (message broker)
- Use-case: audit log, notification, analytics, cache invalidation
- Cẩn thận: event storm + khó trace → cần logging/correlation id

---

## Task 12 — Command (đóng gói hành động, hỗ trợ queue/retry)
**Mục đích:** Chuẩn hóa “1 hành động” thành object để retry, log, queue.

**Keypoint cần học**
- Command object: input + handler
- Use-case: job queue, background processing, undo/redo (UI)
- Kết hợp với Mediator (framework) nếu có
- Idempotency quan trọng khi retry

---

## Task 13 — Chain of Responsibility (pipeline/handlers)
**Mục đích:** Xây pipeline xử lý nhiều bước mà có thể thêm/bớt bước.

**Keypoint cần học**
- Use-case: middleware HTTP, validation chain, anti-fraud checks
- Handler quyết định pass/stop
- Dễ cấu hình theo environment
- Tránh chain quá dài khó debug → cần tracing/log

---

## Task 14 — Decorator (thêm tính năng mà không sửa class gốc)
**Mục đích:** Bổ sung cross-cutting concerns: caching, logging, retry.

**Keypoint cần học**
- Wrap interface bằng decorator: `CachingX`, `LoggingX`
- Use-case: API client, repository, service
- Tránh tạo quá nhiều decorator rối → dùng cho concerns rõ ràng
- Phù hợp với DI container

---

## Task 15 — Specification (filter/search rules) (enterprise search)
**Mục đích:** Gom điều kiện lọc phức tạp thành object có thể combine.

**Keypoint cần học**
- Use-case: search/filter nhiều điều kiện
- Combine: AND/OR/NOT
- Dễ test từng rule
- Mapping sang query (ORM/SQL) cần cẩn thận

---

## Task 16 — Anti-patterns cần tránh (quan trọng hơn học thêm pattern)
**Mục đích:** Tránh codebase enterprise “thối” nhanh.

**Keypoint cần học**
- God Object / Fat Controller / Anemic Domain (khi không chủ ý)
- Over-abstraction (interface cho mọi thứ)
- Service Locator
- “Generic Repository” lạm dụng
- Pattern làm mục tiêu thay vì giải quyết vấn đề

---

## Task 17 — Lộ trình áp dụng thực chiến theo use-case (đúng enterprise)
**Mục đích:** Biết chọn pattern theo vấn đề thực tế, không học thuộc.

**Keypoint cần học**
- API module chuẩn: Controller → Service (use-case) → Repo/Adapters
- Cross-cutting: Decorator (logging/caching/retry)
- Business rules: Strategy + Specification
- Integration: Adapter + Facade
- Async: Command + Events (Observer/PubSub)
- Pipelines: Chain of Responsibility (middlewares/validators)

---

## Task 18 — “Hero checklist” (đủ pattern để đi làm enterprise)
**Mục đích:** Tự đánh giá đã nắm đủ chưa.

**Keypoint cần học**
- Bạn biết dùng DI để tách phụ thuộc và test
- Biết thay if-else rule bằng Strategy/Specification
- Biết tách tích hợp ngoài bằng Adapter/Facade
- Biết tách data access bằng Repository + transaction boundary rõ
- Biết chuẩn hóa input/output bằng DTO + Mapper
- Biết xử lý async/mở rộng bằng Events/Command
- Biết thêm caching/logging/retry bằng Decorator
- Quan trọng: biết khi nào KHÔNG dùng pattern

---
