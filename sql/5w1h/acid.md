# ACID — Database Transactions 5W1H

## What

**ACID** là tập hợp 4 thuộc tính đảm bảo **transaction** trong database được thực thi đáng tin cậy. Khái niệm gốc do Jim Gray formalize năm 1981, viết tắt cho:

| Property | Ý nghĩa cốt lõi |
|---|---|
| **A**tomicity | Transaction là **all-or-nothing** — hoặc toàn bộ commit, hoặc rollback hoàn toàn. Không có trạng thái nửa vời. |
| **C**onsistency | Transaction đưa DB từ **valid state này sang valid state khác**, tôn trọng mọi constraint (PK, FK, CHECK, trigger, business rule). |
| **I**solation | Các transaction chạy đồng thời không "thấy" trạng thái trung gian của nhau — kết quả như thể chạy tuần tự (serializable). |
| **D**urability | Khi transaction đã commit, kết quả **persist** kể cả crash, mất điện, restart. |

### Transaction là gì?

Một đơn vị logic gồm 1 hoặc nhiều operation (INSERT/UPDATE/DELETE/SELECT) phải được xử lý như **một khối duy nhất**.

```sql
BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
-- Hoặc cả 2 update thành công, hoặc cả 2 không xảy ra.
```

---

## Why

- **Data integrity**: Tránh tình trạng dữ liệu hỏng, mâu thuẫn, mất mát.
- **Concurrency safety**: Nhiều user/process cùng đọc-ghi vẫn cho kết quả đúng.
- **Crash recovery**: Sau crash, DB phải khôi phục về trạng thái nhất quán.
- **Business correctness**: Các nghiệp vụ tài chính, đặt vé, kho hàng... bắt buộc cần ACID — không có chỗ cho "gần đúng".

**Phản ví dụ — không có ACID:**
- Atomicity vỡ: trừ tiền tài khoản A nhưng chưa cộng vào B → mất tiền.
- Isolation vỡ: 2 user cùng đặt vé cuối cùng → bán trùng.
- Durability vỡ: confirm đơn hàng xong, server reboot → đơn biến mất.

---

## When (khi nào cần / không cần ACID đầy đủ)

### Cần ACID mạnh
- Hệ thống tài chính (banking, payment, accounting).
- Inventory, booking, ticketing — chỗ có **contention** trên resource hữu hạn.
- ERP, CRM, hệ thống có business rule phức tạp.
- Bất kỳ chỗ nào "sai 1 record = mất tiền / mất khách / kiện tụng".

### Có thể nới lỏng (BASE / eventual consistency)
- Analytics, logging, metrics aggregation.
- Social feed, like count, view count.
- Cache layer, CDN content.
- Hệ thống ưu tiên **availability + horizontal scale** hơn strong consistency (theo **CAP theorem**).

> ACID ↔ BASE: BASE = **B**asically **A**vailable, **S**oft state, **E**ventually consistent — đại diện cho NoSQL style (Cassandra, DynamoDB default mode...).

---

## Where (DB nào hỗ trợ, cơ chế thế nào)

| DB | ACID? | Cơ chế chính |
|---|---|---|
| **PostgreSQL** | Full ACID | MVCC + WAL |
| **Oracle** | Full ACID | MVCC (undo segment) + Redo log |
| **MySQL InnoDB** | Full ACID | MVCC + Redo/Undo log |
| **MySQL MyISAM** | ❌ Không có transaction | (legacy, tránh dùng) |
| **SQL Server** | Full ACID | Locking + WAL (transaction log) |
| **MongoDB 4.0+** | ACID multi-document (replica set), 4.2+ sharded | Snapshot isolation |
| **Cassandra** | Row-level atomicity, **không** multi-row ACID | Eventual consistency (BASE) |
| **DynamoDB** | Single-item ACID, transactions API cho multi-item | Optimistic concurrency |
| **Redis** | Single-command atomic, MULTI/EXEC pseudo-transaction | Không có rollback thực sự |
| **SQLite** | Full ACID | Rollback journal / WAL |

### Cơ chế kỹ thuật cốt lõi

| Property | Implementation |
|---|---|
| Atomicity | **Undo log** / rollback segment — revert change khi abort |
| Consistency | **Constraints + triggers** ở DB engine + application logic |
| Isolation | **Locking** (2PL) hoặc **MVCC** (snapshot per transaction) |
| Durability | **WAL (Write-Ahead Logging)** — flush log to disk trước data page, `fsync` |

---

## Who (so sánh isolation levels — phần dễ hiểu sai nhất)

SQL standard định nghĩa 4 isolation level. Càng cao, càng "isolation đúng" nhưng càng **giảm concurrency**.

| Level | Dirty Read | Non-repeatable Read | Phantom Read | Serialization Anomaly |
|---|---|---|---|---|
| **READ UNCOMMITTED** | ✅ có | ✅ có | ✅ có | ✅ có |
| **READ COMMITTED** | ❌ | ✅ có | ✅ có | ✅ có |
| **REPEATABLE READ** | ❌ | ❌ | ✅ có (*) | ✅ có |
| **SERIALIZABLE** | ❌ | ❌ | ❌ | ❌ |

(*) PostgreSQL REPEATABLE READ thực ra là **snapshot isolation** — chặn cả phantom, nhưng vẫn có serialization anomaly.

### Default isolation của các DB phổ biến

| DB | Default |
|---|---|
| Oracle | READ COMMITTED |
| PostgreSQL | READ COMMITTED |
| MySQL InnoDB | **REPEATABLE READ** ⚠️ (khác với phần lớn DB khác) |
| SQL Server | READ COMMITTED |

> Lưu ý: Default MySQL khác Oracle/PostgreSQL → khi migrate code giữa các DB phải kiểm tra rất kỹ.

### Phenomena giải thích

- **Dirty Read**: Đọc được data của transaction khác **chưa commit**.
- **Non-repeatable Read**: Đọc cùng 1 row 2 lần trong cùng transaction → khác nhau (vì transaction khác đã UPDATE + COMMIT).
- **Phantom Read**: Đọc cùng 1 range 2 lần → số row khác nhau (vì transaction khác INSERT + COMMIT).
- **Lost Update**: 2 transaction đọc cùng giá trị, cùng update → 1 update bị ghi đè mất.

---

## How

### 1. Cú pháp transaction cơ bản

```sql
-- Standard SQL
BEGIN;  -- hoặc START TRANSACTION
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;  -- hoặc ROLLBACK nếu lỗi

-- Set isolation level cho session
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### 2. Savepoint — partial rollback

```sql
BEGIN;
  INSERT INTO orders (...) VALUES (...);
  SAVEPOINT sp1;
  INSERT INTO order_items (...) VALUES (...);  -- fail
  ROLLBACK TO SAVEPOINT sp1;  -- chỉ rollback từ sp1 trở đi
  -- order vẫn còn
COMMIT;
```

### 3. Pessimistic vs Optimistic locking

**Pessimistic — `SELECT ... FOR UPDATE`:**
```sql
BEGIN;
  SELECT balance FROM accounts WHERE id = 1 FOR UPDATE;  -- lock row
  -- ... tính toán, không ai sửa được row này ...
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT;
```

**Optimistic — version column:**
```sql
-- Đọc
SELECT balance, version FROM accounts WHERE id = 1;
-- (version = 5)

-- Ghi: chỉ thành công nếu version chưa đổi
UPDATE accounts
SET    balance = ?, version = version + 1
WHERE  id = 1 AND version = 5;

-- Nếu affected rows = 0 → ai đó đã update → retry/abort
```

### 4. Distributed transaction — 2 Phase Commit (2PC)

Khi transaction span nhiều DB/service:

```
Phase 1 (Prepare): Coordinator hỏi tất cả participant "Bạn sẵn sàng commit?"
                   Mỗi participant write-ahead log + reply YES/NO
Phase 2 (Commit):  Nếu tất cả YES → coordinator gửi COMMIT
                   Nếu có NO → coordinator gửi ROLLBACK
```

Vấn đề: blocking nếu coordinator crash → thực tế microservices thường dùng **Saga pattern** thay thế (compensating transaction), đánh đổi atomicity đầy đủ lấy availability.

### 5. Pattern phổ biến trong code

**Java/Spring:**
```java
@Transactional(isolation = Isolation.REPEATABLE_READ,
               rollbackFor = Exception.class)
public void transfer(Long fromId, Long toId, BigDecimal amount) {
    accountRepo.withdraw(fromId, amount);
    accountRepo.deposit(toId, amount);
    // commit tự động khi method return, rollback nếu Exception
}
```

**Laravel/PHP:**
```php
DB::transaction(function () use ($from, $to, $amount) {
    Account::where('id', $from)->decrement('balance', $amount);
    Account::where('id', $to)->increment('balance', $amount);
}, 3); // retry 3 lần nếu deadlock
```

### 6. Gotchas thực tế

1. **Long-running transaction**: Giữ lock lâu → block transaction khác, bloat undo log. Giữ transaction **càng ngắn càng tốt**.

2. **Implicit commit**: DDL (CREATE TABLE, ALTER...) trong nhiều DB (MySQL, Oracle) auto-commit → phá vỡ transaction đang mở.

3. **Auto-commit mode**: Default ở nhiều client → mỗi statement là 1 transaction → mất atomicity nếu không `BEGIN` explicit.

4. **Deadlock**: 2 transaction wait lẫn nhau → DB detect & kill một bên (`ORA-00060`, `Deadlock found` ở MySQL). Code phải handle retry.

5. **MySQL REPEATABLE READ ≠ Oracle/PostgreSQL**: Sử dụng gap lock → behavior khác với snapshot isolation thuần.

6. **`COMMIT` không đảm bảo durability nếu `innodb_flush_log_at_trx_commit ≠ 1`** (MySQL) hoặc `synchronous_commit = off` (PostgreSQL). Đây là trade-off performance vs durability.

7. **ORM lazy-loading ngoài transaction**: Hibernate, JPA dễ vấp `LazyInitializationException` nếu access proxy sau khi transaction đóng.

---

## Summary cheat-sheet

```
┌─────────────────────────────────────────────────────────┐
│  ACID = Atomicity · Consistency · Isolation · Durability│
├─────────────────────────────────────────────────────────┤
│  A → Undo log (rollback all-or-nothing)                 │
│  C → Constraints + business invariants                  │
│  I → Locking / MVCC, 4 isolation levels                 │
│  D → WAL + fsync (survive crash)                        │
├─────────────────────────────────────────────────────────┤
│  CAP: distributed system phải đánh đổi C ↔ A khi P xảy ra│
│  BASE: alternative cho hệ thống scale-out, eventual consistency │
└─────────────────────────────────────────────────────────┘
```