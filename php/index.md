# PHP ZERO → HERO (Enterprise) — Task-based Learning Plan

> Mục tiêu tổng: từ nền tảng PHP → viết code sạch & maintainable → làm web/API production → bảo mật, hiệu năng → vận hành enterprise (CI/CD, monitoring, scaling).

---

## TASK 01 — Setup môi trường dev chuẩn enterprise
**Mục đích**
- Có môi trường tái lập (reproducible) giống production để tránh “chạy máy em”.
- Làm việc nhóm dễ (Docker, .env, chuẩn hóa PHP extensions).

**Keypoint**
- PHP versions (8.x), php.ini cơ bản, extensions phổ biến (pdo, mbstring, intl, opcache)
- Docker/Docker Compose (nginx/apache + php-fpm + mysql/pgsql + redis)
- Xdebug (debug), Composer (dependency), dotenv (.env)
- Coding font/IDE config, lint/format baseline

---

## TASK 02 — PHP syntax nền tảng (viết đúng, không “học vẹt”)
**Mục đích**
- Viết được code chạy ổn, ít bug cơ bản.
- Nắm kiểu dữ liệu và hành vi runtime của PHP.

**Keypoint**
- Variables, scalar types, arrays, strings
- Strict types: `declare(strict_types=1);`
- Operators, comparisons (`==` vs `===`), null coalescing `??`, nullsafe `?->`
- Control flow, functions, default params, named arguments
- Error/Exception khác nhau thế nào

---

## TASK 03 — Arrays & data handling (trái tim của PHP backend)
**Mục đích**
- Xử lý data (request/response/DB) đúng và gọn.
- Tránh code rối khi transform dữ liệu.

**Keypoint**
- Array functions: `array_map/filter/reduce`, `array_column`, `usort`
- JSON encode/decode đúng (unicode, float, depth, error handling)
- DateTime/DateTimeImmutable, timezone
- Input normalization (trim, sanitize, cast)

---

## TASK 04 — Error handling & logging đúng chuẩn production
**Mục đích**
- Không “die/var_dump” trong production.
- Debug nhanh khi incident.

**Keypoint**
- Exceptions, custom exceptions, try/catch/finally
- Error levels, error handler
- Logging theo level (debug/info/warn/error)
- Correlation id / request id (trace theo request)

---

## TASK 05 — OOP core (bắt buộc cho enterprise PHP)
**Mục đích**
- Code dễ mở rộng, dễ test, dễ maintain.
- Hợp tác tốt trong team.

**Keypoint**
- Class, interface, abstract, trait: dùng đúng – tránh lạm dụng
- Visibility, immutability, DTO/Value Object
- Constructor property promotion, readonly properties
- SOLID cơ bản (đặc biệt SRP, DIP)

---

## TASK 06 — Composer, Autoload, PSR (chuẩn hóa dự án)
**Mục đích**
- Quản lý dependencies đúng cách.
- Dự án theo chuẩn cộng đồng/enterprise.

**Keypoint**
- Composer basics: require, scripts, autoload (PSR-4)
- PSR-1/PSR-12 (coding style), PSR-3 (logger), PSR-4 (autoload)
- SemVer, lock file, dependency security awareness
- Namespace design, folder structure

---

## TASK 07 — HTTP fundamentals cho backend/API
**Mục đích**
- Hiểu request/response để xây API đúng và debug đúng.
- Tránh lỗi thiết kế API gây khổ về sau.

**Keypoint**
- HTTP methods, status codes, headers
- Content negotiation (Accept/Content-Type)
- Cookies vs sessions vs tokens
- CORS basics
- Idempotency (PUT/DELETE), pagination, filtering

---

## TASK 08 — Build REST API chuẩn enterprise (thiết kế & convention)
**Mục đích**
- API ổn định, dễ dùng, dễ versioning.
- Tránh breaking change.

**Keypoint**
- Resource naming, versioning strategy
- Validation & error response format thống nhất
- Rate limit / throttling
- API documentation (OpenAPI/Swagger)
- DTO/Request/Response mapping

---

## TASK 09 — Database fundamentals (SQL + PHP data layer)
**Mục đích**
- Làm việc với dữ liệu chắc chắn, tránh SQL injection & bug transaction.
- Tư duy đúng khi optimize.

**Keypoint**
- PDO basics, prepared statements
- Transactions, isolation (khái niệm), deadlock awareness
- Index basics (đủ để làm việc)
- Migration mindset (schema as code)

---

## TASK 10 — ORM/Query Builder (thực chiến doanh nghiệp)
**Mục đích**
- Tăng tốc phát triển, giảm boilerplate.
- Nhưng vẫn kiểm soát được performance.

**Keypoint**
- ORM vs Query Builder: khi nào dùng cái nào
- N+1 query problem & cách tránh (eager loading)
- Pagination, filtering, sorting
- Raw query an toàn khi cần tối ưu

---

## TASK 11 — Framework enterprise (chọn 1: Laravel hoặc Symfony)
**Mục đích**
- Làm dự án enterprise nhanh, có ecosystem.
- Học đúng “framework way” để team maintain.

**Keypoint**
- Routing, middleware, controller/service/repository layering
- DI container, config, env
- Validation, policies/authorization
- Jobs/queue, events, scheduling

> Gợi ý thực dụng: Laravel phổ biến sản phẩm nhanh; Symfony mạnh hệ thống lớn & component hóa.

---

## TASK 12 — Authentication & Authorization (bảo mật nền)
**Mục đích**
- Đảm bảo đúng user, đúng quyền, đúng data.
- Đây là nhu cầu top của doanh nghiệp.

**Keypoint**
- Auth: session-based vs token-based (JWT/OAuth2)
- Authorization: RBAC/ABAC, policy, permission
- Password hashing (bcrypt/argon2), reset flow
- CSRF/XSS basics, secure cookies, SameSite

---

## TASK 13 — Input validation & data integrity
**Mục đích**
- Chặn lỗi ngay cửa vào, tránh rác vào DB.
- Giảm bug & giảm chi phí fix.

**Keypoint**
- Validation rules: type/length/format/range
- Normalize input (trim, convert)
- Domain validation vs request validation
- Error message chuẩn hoá cho frontend

---

## TASK 14 — Testing (unit/integration/feature) + test strategy
**Mục đích**
- Dự án enterprise bắt buộc có test để release an toàn.
- Giảm regression.

**Keypoint**
- PHPUnit, mocking, test doubles
- Unit vs Integration vs Feature tests
- Test database strategy (transaction rollback, sqlite, docker db)
- Coverage hợp lý (không chạy theo % mù)

---

## TASK 15 — Code quality: static analysis + lint + style
**Mục đích**
- Ngăn bug trước khi runtime.
- Team code đồng nhất.

**Keypoint**
- PHPStan/Psalm (static analysis)
- PHP-CS-Fixer/Pint (format)
- Rector (refactor tự động)
- Pre-commit hooks, CI checks

---

## TASK 16 — Security thực chiến (OWASP cho PHP)
**Mục đích**
- Tránh các lỗ hổng phổ biến gây mất dữ liệu/uy tín.

**Keypoint**
- SQL injection, XSS, CSRF, SSRF, RCE (nhận biết & phòng)
- File upload security (mime, size, storage, scan)
- Secrets management (.env, vault concept)
- Dependency vulnerabilities (composer audit)

---

## TASK 17 — Performance & scalability (tư duy production)
**Mục đích**
- API nhanh, ổn định khi tăng tải.
- Giảm cost infra.

**Keypoint**
- PHP-FPM tuning basics, OPcache
- Profiling (Xdebug profiler / blackfire concept)
- Query optimization (index, avoid N+1)
- Caching strategies (HTTP cache, Redis, application cache)

---

## TASK 18 — Async/Queue/Jobs (bắt buộc trong enterprise)
**Mục đích**
- Tách tác vụ nặng khỏi request để giảm latency và tăng reliability.

**Keypoint**
- Queue concepts: producer/consumer, retry, backoff
- Idempotency cho job
- Dead-letter / failed jobs
- Use cases: email, export, sync, batch processing

---

## TASK 19 — Event-driven & integration (hệ thống doanh nghiệp luôn tích hợp)
**Mục đích**
- Tích hợp service khác ổn định, giảm coupling.

**Keypoint**
- Events/listeners, outbox pattern (khái niệm)
- Webhook design (signature, replay protection)
- Message broker basics (RabbitMQ/Kafka concept)
- API client patterns + timeout/retry/circuit breaker (khái niệm)

---

## TASK 20 — Observability: logging, metrics, tracing
**Mục đích**
- Khi production lỗi: tìm nguyên nhân nhanh (MTTR thấp).

**Keypoint**
- Structured logging (JSON), correlation id
- Metrics cơ bản (latency, error rate, throughput)
- Tracing (OpenTelemetry concept)
- Alerting mindset (SLO/SLA concept)

---

## TASK 21 — CI/CD & release strategy
**Mục đích**
- Deploy tự động, an toàn, rollback được.

**Keypoint**
- Pipeline: lint → static analysis → tests → build → deploy
- Env separation: dev/stg/prod
- Migration chạy an toàn
- Blue/green / canary concepts

---

## TASK 22 — Docker & deployment baseline (enterprise ops)
**Mục đích**
- Đóng gói runtime ổn định, dễ scale.

**Keypoint**
- Dockerfile best practices (multi-stage, non-root)
- Nginx + PHP-FPM architecture
- Healthcheck, readiness/liveness concept
- Config via env, secrets handling

---

## TASK 23 — Architecture & patterns cho dự án lớn
**Mục đích**
- Codebase lớn vẫn maintain được.

**Keypoint**
- Layered architecture: Controller/Service/Repository
- DTO/Mapper, domain services
- Dependency inversion, modularization
- Anti-pattern: god class, fat controller, tight coupling

---

## TASK 24 — Data lớn: batch, export/import, streaming mindset
**Mục đích**
- Xử lý file lớn & dữ liệu lớn không sập RAM/timeouts.

**Keypoint**
- Chunk processing, cursor pagination
- Streaming response (download), CSV/Excel export safe
- Timeouts, memory limit, backpressure concept
- Background processing cho job nặng

---

## TASK 25 — “Hero checklist” (chuẩn năng lực enterprise)
**Mục đích**
- Tự đánh giá đã đủ làm production/lead chưa.

**Keypoint**
- Viết API chuẩn, validation chuẩn, error format thống nhất
- Auth/Authorization chắc, chống OWASP top issues
- Query không N+1, có cache hợp lý, có queue cho tác vụ nặng
- Có test + CI checks + deploy an toàn
- Có logging/metrics đủ để vận hành & debug production

---

## Gợi ý học theo timeline (thực tế)
- 2–3 tuần: TASK 01–06 (nền + chuẩn hóa)
- 3–4 tuần: TASK 07–13 (web/API + security nền)
- 3–4 tuần: TASK 14–18 (test + quality + performance + queue)
- 4+ tuần: TASK 19–25 (integration + observability + ops + architecture)

---

## Nếu bạn muốn mình “cá nhân hoá” roadmap
Chọn 1 stack mục tiêu để mình viết tiếp theo từng task kèm ví dụ code & bài tập:
- Laravel (phổ biến) / Symfony (enterprise component)
- DB: MySQL/PostgreSQL
- Queue: Redis/RabbitMQ
- Deploy: Docker + Nginx + PHP-FPM