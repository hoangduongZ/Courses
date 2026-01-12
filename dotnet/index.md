# C# ZERO → HERO (Enterprise) — Task-based Learning Plan

> Mục tiêu tổng: từ nền tảng C#/.NET → viết code sạch & maintainable → build API/service production → performance + security + testing + cloud/ops chuẩn enterprise.

---

## TASK 01 — Setup môi trường .NET chuẩn enterprise
**Mục đích**
- Làm việc thống nhất trong team, build chạy giống nhau dev/stg/prod.
- Tránh “máy em chạy được”.

**Keypoint**
- Cài .NET SDK (LTS), Visual Studio / Rider / VS Code
- `dotnet` CLI: new/build/run/test/publish
- NuGet basics, `global.json` pin SDK
- Solution/project structure: `.sln`, `.csproj`
- EditorConfig + analyzers baseline

---

## TASK 02 — C# syntax nền tảng (viết đúng ngay từ đầu)
**Mục đích**
- Nắm chắc cú pháp & hành vi runtime để tránh bug cơ bản.

**Keypoint**
- Types (value vs reference), `var`, nullable reference types
- Control flow: if/switch/loops
- Methods, optional/named parameters
- String interpolation, formatting
- Exceptions basics (try/catch/finally)

---

## TASK 03 — Collections & Generics (data handling enterprise)
**Mục đích**
- Xử lý dữ liệu hiệu quả và an toàn kiểu (type-safe).

**Keypoint**
- `List<T>`, `Dictionary<TKey,TValue>`, `HashSet<T>`
- `IEnumerable<T>` vs `ICollection<T>` vs `IList<T>`
- Generics constraints (biết dùng)
- Immutability basics (records/readonly)

---

## TASK 04 — OOP core: class/interface/abstract (bắt buộc)
**Mục đích**
- Code dễ mở rộng, dễ test, dễ maintain trong dự án lớn.

**Keypoint**
- Class, interface, abstract class
- Encapsulation, inheritance, polymorphism
- Dependency inversion (DIP) concept
- Composition over inheritance

---

## TASK 05 — Modern C# features (để code enterprise gọn và an toàn)
**Mục đích**
- Viết code ngắn gọn nhưng rõ ràng, giảm bug.

**Keypoint**
- Records, init-only, `required` (nếu dùng)
- Pattern matching, switch expressions
- Null-coalescing `??`, null-conditional `?.`
- `using` declarations, `IDisposable`
- `Span<T>` awareness (khái niệm performance)

---

## TASK 06 — LINQ (vũ khí xử lý dữ liệu)
**Mục đích**
- Viết logic xử lý collection/query sạch, readable.
- Dùng đúng để không tạo bottleneck.

**Keypoint**
- `Select/Where/Any/All/GroupBy/Join`
- Deferred execution vs immediate execution (`ToList`)
- Pitfalls: multiple enumeration, performance
- LINQ to Objects vs LINQ to Entities (khác nhau quan trọng)

---

## TASK 07 — Asynchronous programming: async/await (enterprise bắt buộc)
**Mục đích**
- Xây API/service không block thread, scale tốt.

**Keypoint**
- `Task`, `async/await`
- CancellationToken
- ConfigureAwait awareness
- Common pitfalls: deadlocks, fire-and-forget
- Parallelism vs concurrency (khái niệm)

---

## TASK 08 — Error handling & logging chuẩn production
**Mục đích**
- Debug nhanh khi incident, log có cấu trúc.

**Keypoint**
- Exception strategy: catch đúng nơi
- Custom exceptions + error codes concept
- Logging: structured logging (Serilog/MEL)
- CorrelationId/TraceId (request tracing mindset)

---

## TASK 09 — Build REST API với ASP.NET Core (core enterprise)
**Mục đích**
- Xây API chuẩn, maintain được, dễ test.

**Keypoint**
- Controllers vs Minimal APIs (khi nào dùng)
- Routing, model binding
- Validation: DataAnnotations/FluentValidation
- Response conventions, ProblemDetails
- API versioning concept, Swagger/OpenAPI

---

## TASK 10 — Dependency Injection (DI) & Middleware pipeline
**Mục đích**
- Kiến trúc enterprise: loose coupling, testable.

**Keypoint**
- DI container built-in
- Lifetime: Transient/Scoped/Singleton (rất quan trọng)
- Middleware pipeline, filters
- Options pattern (`IOptions<T>`)
- Configuration & environment (appsettings, secrets)

---

## TASK 11 — Authentication & Authorization (security baseline)
**Mục đích**
- Doanh nghiệp yêu cầu phân quyền chặt; tránh lộ data.

**Keypoint**
- Authentication: JWT/OAuth2/OpenID Connect concepts
- Authorization: roles/policies/claims
- Secure password storage (khi có local accounts)
- CSRF (nếu cookie auth), CORS
- Security headers basics

---

## TASK 12 — Database access: EF Core + SQL fundamentals
**Mục đích**
- Làm việc dữ liệu an toàn, tối ưu, đúng transaction.

**Keypoint**
- DbContext, migrations
- Tracking vs NoTracking
- N+1 problem & Include
- Transactions, concurrency token (rowversion)
- Raw SQL khi cần performance (an toàn)

---

## TASK 13 — Performance basics cho .NET services
**Mục đích**
- API nhanh, ít GC pressure, scale tốt.

**Keypoint**
- GC basics, allocations awareness
- Avoid sync-over-async
- Caching: IMemoryCache/Distributed cache concept
- Response compression, pagination
- Profiling: dotnet-trace/dotnet-counters concept

---

## TASK 14 — Testing: Unit/Integration/Contract tests
**Mục đích**
- Enterprise cần test để release an toàn, giảm regression.

**Keypoint**
- xUnit/NUnit + mocking (Moq)
- Test pyramid
- Integration test với WebApplicationFactory
- Test DB strategy (in-memory vs container)
- Contract testing concept (nếu microservices)

---

## TASK 15 — Code quality: analyzers, style, static checks
**Mục đích**
- Ngăn bug trước runtime, code đồng nhất team.

**Keypoint**
- .editorconfig, Roslyn analyzers
- Nullable warnings (treat as errors)
- Formatting (dotnet format)
- SonarQube concept
- Dependency scanning concept

---

## TASK 16 — Background jobs & messaging (enterprise async workflows)
**Mục đích**
- Tách tác vụ nặng khỏi request; đảm bảo reliability.

**Keypoint**
- Hosted Services (BackgroundService)
- Queues: RabbitMQ/SQS/Kafka concepts
- Retry/backoff, idempotency
- Outbox pattern concept
- Dead-letter queue concept

---

## TASK 17 — Observability: metrics/tracing/health checks
**Mục đích**
- Vận hành production: biết hệ thống đang khỏe hay lỗi.

**Keypoint**
- Health checks endpoints
- OpenTelemetry concept (traces, metrics)
- Structured logs + correlation
- Alerts (error rate, latency p95)
- Dashboards basics

---

## TASK 18 — Deployment & CI/CD (enterprise delivery)
**Mục đích**
- Build/publish/deploy ổn định, rollback được.

**Keypoint**
- `dotnet publish` (self-contained vs framework-dependent)
- Docker for .NET (multi-stage)
- Environment configs, secrets
- Blue/green/canary concepts
- GitHub Actions/Azure DevOps pipelines concept

---

## TASK 19 — Architecture patterns cho hệ thống lớn
**Mục đích**
- Codebase lớn vẫn maintain; dễ mở rộng team.

**Keypoint**
- Layered architecture (API/Application/Domain/Infrastructure)
- Clean Architecture basics
- CQRS concept (khi nào cần)
- Domain-driven design (high-level)
- Anti-patterns: fat controllers, god services

---

## TASK 20 — “Hero checklist” (chuẩn enterprise)
**Mục đích**
- Tự đánh giá đã đủ làm production/lead chưa.

**Keypoint**
- Viết API chuẩn: validation, error format, swagger
- DI đúng lifetime, code testable
- AuthZ chắc: policies/claims, least privilege
- EF Core tránh N+1, query tối ưu, transaction đúng
- Có test + CI checks + deploy pipeline
- Có logs/metrics/traces/healthchecks để vận hành

---

## Suggested learning order (thực tế)
- 2–3 tuần: TASK 01–06 (nền + OOP + LINQ)
- 2–3 tuần: TASK 07–12 (async + API + DI + security + DB)
- 3–5 tuần: TASK 13–18 (performance + testing + observability + deploy)
- Liên tục: TASK 19–20 (architecture + mastery)