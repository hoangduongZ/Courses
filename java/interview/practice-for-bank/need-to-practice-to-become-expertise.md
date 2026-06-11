# Java Expertise Roadmap

## Core Topics cần nắm
- Collection
- Lambda
- Generic
- Multithreading

---

## Phase 1 — Java Concurrency Core

> Đừng học theo kiểu nhớ API — hãy học theo vấn đề thực tế.

### Danh sách cần practice

| Nhóm | API / Concept |
|------|--------------|
| Thread cơ bản | `Thread`, `Runnable`, `Callable`, `Future` |
| Async / Compose | `CompletableFuture` |
| Thread Pool | `ExecutorService`, `ThreadPoolExecutor`, `ScheduledExecutorService` |
| Thread-safe data | `ConcurrentHashMap`, `BlockingQueue` |
| Atomic | `AtomicInteger`, `AtomicLong` |
| Locking | `synchronized`, `ReentrantLock`, `volatile` |
| Coordination | `CountDownLatch`, `Semaphore` |

### Học theo vấn đề thực tế

| Vấn đề thực tế | Java tool cần luyện |
|----------------|---------------------|
| Chạy task nền | `ExecutorService` |
| Gọi nhiều API song song | `CompletableFuture` |
| Gom kết quả nhiều task | `allOf` / `thenCombine` |
| Task A xong mới chạy task B | `thenCompose` |
| Timeout / fallback | `orTimeout` / `completeOnTimeout` |
| Producer tạo job, consumer xử lý | `BlockingQueue` |
| Nhiều thread update chung dữ liệu | `Lock` / `Atomic` / `ConcurrentHashMap` |
| Giới hạn số task chạy cùng lúc | `Semaphore` |
| Chạy định kỳ | `ScheduledExecutorService` |

---

## Phase 2 — Event-driven + Kafka + Data Correctness

### Yêu cầu của hệ thống Banking

- Không mất message
- Không xử lý trùng tiền
- Đúng thứ tự khi cần
- Có retry
- Có Dead Letter Queue
- Có audit log
- Có reconciliation
- Có idempotency
- Transaction boundary rõ ràng

### Concepts cần luyện mạnh

| Nhóm | Concept |
|------|---------|
| Message Broker | Kafka, RabbitMQ |
| Kafka internals | Consumer Group, Partition, Offset |
| Reliability | Retry, Dead Letter Queue (DLQ) |
| Data correctness | Idempotency Key, Outbox Pattern |
| Distributed transaction | Saga Pattern, Transaction Compensation |
| Consistency model | Eventual Consistency |

---

## Mini Project — Payment Processing System

> Mục tiêu: luyện toàn bộ Phase 2 trong một hệ thống thực tế.

```
1.  User gọi API tạo giao dịch chuyển tiền
2.  API lưu transaction với status = PENDING
3.  Ghi event vào outbox table
4.  Background worker publish event sang Kafka
5.  Consumer nhận event
6.  Kiểm tra idempotency_key (tránh xử lý trùng)
7.  Xử lý debit / credit
8.  Update status = SUCCESS hoặc FAILED
9.  Nếu lỗi tạm thời → retry
10. Nếu lỗi quá số lần → đưa vào DLQ
11. Có API reconciliation để check giao dịch bị treo
```
