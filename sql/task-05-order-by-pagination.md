# TASK 05 — ORDER BY & Pagination theo Chuẩn Production

> **Mục tiêu**: Pagination sai là sát thủ performance khi data lớn. Học cách làm đúng.

---

## 1. THEORY — ORDER BY và Chi phí Sort

### 1.1. ORDER BY trong execution pipeline

```
Query Execution:
┌──────────────────────────────────────────────┐
│ 1. FROM/JOIN    → Lấy/Join tables           │
│ 2. WHERE        → Filter rows                │
│ 3. GROUP BY     → Group rows                 │
│ 4. HAVING       → Filter groups              │
│ 5. SELECT       → Project columns            │
│ 6. ORDER BY     → SORT (tốn CPU + memory!)   │
│ 7. LIMIT/OFFSET → Chọn subset                │
└──────────────────────────────────────────────┘
```

**ORDER BY = Expensive operation:**
- Phải xử lý TẤT CẢ rows trước khi sort
- Cần memory để sort (nếu không đủ → disk temporary file)
- CPU intensive

---

### 1.2. Sort Cost Analysis

#### **In-memory sort (GOOD)**
```sql
-- 1000 rows, đủ memory
SELECT * FROM orders 
ORDER BY order_date DESC 
LIMIT 10;

Cost:
- Read: 1000 rows
- Sort in memory: ~10ms
- Return: 10 rows
Total: ~15ms ✅
```

#### **External sort (BAD)**
```sql
-- 10M rows, không đủ memory
SELECT * FROM orders 
ORDER BY order_date DESC 
LIMIT 10;

Cost:
- Read: 10M rows → 500MB+
- Sort on disk (temp file): ~5000ms
- Return: 10 rows
Total: ~5000ms+ ❌
```

**work_mem configuration (PostgreSQL):**
```sql
-- Check current setting
SHOW work_mem;  -- Default: 4MB

-- Set larger for session (if needed)
SET work_mem = '256MB';

-- But: Không phải giải pháp tốt nhất!
-- Better: Dùng INDEX để tránh sort
```

---

### 1.3. Index eliminates sorting

#### **Without Index**
```sql
-- No index on order_date
EXPLAIN ANALYZE
SELECT * FROM orders 
ORDER BY order_date DESC 
LIMIT 10;

-- Plan:
-- Limit
--   -> Sort (cost: high!)
--      -> Seq Scan on orders
-- Execution time: 500ms+ (với 50k rows)
```

#### **With Index**
```sql
-- Create index
CREATE INDEX idx_orders_date_desc ON orders(order_date DESC);

EXPLAIN ANALYZE
SELECT * FROM orders 
ORDER BY order_date DESC 
LIMIT 10;

-- Plan:
-- Limit
--   -> Index Scan Backward using idx_orders_date_desc
-- Execution time: <1ms ✅

-- NO SORT NEEDED! Index đã sorted
```

**Key insight:**
- Index B-tree đã sorted
- Scan backward = đọc từ cuối lên
- Chỉ đọc 10 rows, không sort!

---

### 1.4. LIMIT/OFFSET - The Performance Killer

#### **Vấn đề với OFFSET**

```sql
-- Page 1 (OFFSET 0)
SELECT * FROM orders 
ORDER BY order_id 
LIMIT 20 OFFSET 0;
-- Execution: Đọc 20 rows ✅

-- Page 10 (OFFSET 180)
SELECT * FROM orders 
ORDER BY order_id 
LIMIT 20 OFFSET 180;
-- Execution: Đọc 200 rows, bỏ 180, lấy 20 ⚠️

-- Page 1000 (OFFSET 19980)
SELECT * FROM orders 
ORDER BY order_id 
LIMIT 20 OFFSET 19980;
-- Execution: Đọc 20,000 rows, bỏ 19,980, lấy 20 ❌

-- Page 10000 (OFFSET 199980)
SELECT * FROM orders 
ORDER BY order_id 
LIMIT 20 OFFSET 199980;
-- Execution: Đọc 200,000 rows, bỏ 199,980, lấy 20 💀
```

**Performance degradation:**
```
Page    OFFSET    Rows Read    Time
1       0         20           1ms
10      180       200          5ms
100     1980      2000         50ms
1000    19980     20000        500ms
10000   199980    200000       5000ms (5 seconds!)
```

**Tại sao?**
- PostgreSQL phải **WALK THROUGH** tất cả rows trước OFFSET
- Không thể skip, vì cần maintain sort order
- OFFSET càng lớn, càng nhiều rows bị đọc rồi bỏ

---

### 1.5. Keyset Pagination (Seek Method) - The Right Way

#### **Concept: "Where we left off"**

**OFFSET method (bad):**
```
"Give me rows 100-120"
→ Đọc 120 rows, bỏ 100 đầu
```

**Keyset method (good):**
```
"Give me 20 rows AFTER order_id = 100"
→ Đọc đúng 20 rows
```

#### **Implementation**

**Page 1:**
```sql
SELECT order_id, order_date, total_amount
FROM orders
ORDER BY order_id DESC
LIMIT 20;

-- Results:
-- order_id: 50000, 49999, 49998, ..., 49981
-- Last order_id: 49981 (remember this!)
```

**Page 2:**
```sql
SELECT order_id, order_date, total_amount
FROM orders
WHERE order_id < 49981  -- Keyset: last value from previous page
ORDER BY order_id DESC
LIMIT 20;

-- Results:
-- order_id: 49980, 49979, ..., 49961
-- Last order_id: 49961
```

**Page 3:**
```sql
SELECT order_id, order_date, total_amount
FROM orders
WHERE order_id < 49961
ORDER BY order_id DESC
LIMIT 20;
```

**Performance:**
```
Page    Method          Rows Read    Time
1       Keyset          20           1ms
10      Keyset          20           1ms
100     Keyset          20           1ms
1000    Keyset          20           1ms
10000   Keyset          20           1ms  ✅ STABLE!

1       OFFSET          20           1ms
10      OFFSET          200          5ms
100     OFFSET          2000         50ms
1000    OFFSET          20000        500ms
10000   OFFSET          200000       5000ms ❌ DEGRADED!
```

---

### 1.6. Keyset Pagination - Complex cases

#### **Multiple sort columns**
```sql
-- Sort by date DESC, then id DESC

-- Page 1
SELECT order_id, order_date, total_amount
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 20;
-- Last: order_date = '2024-01-15', order_id = 12345

-- Page 2
SELECT order_id, order_date, total_amount
FROM orders
WHERE (order_date, order_id) < ('2024-01-15', 12345)
ORDER BY order_date DESC, order_id DESC
LIMIT 20;

-- Index needed:
CREATE INDEX idx_orders_pagination 
ON orders(order_date DESC, order_id DESC);
```

#### **Mixed ASC/DESC**
```sql
-- Sort by status ASC, date DESC

-- Page 1
SELECT order_id, status, order_date
FROM orders
ORDER BY status ASC, order_date DESC
LIMIT 20;
-- Last: status = 'pending', order_date = '2024-01-10'

-- Page 2
SELECT order_id, status, order_date
FROM orders
WHERE (status > 'pending') 
   OR (status = 'pending' AND order_date < '2024-01-10')
ORDER BY status ASC, order_date DESC
LIMIT 20;

-- Index needed:
CREATE INDEX idx_orders_status_date 
ON orders(status ASC, order_date DESC);
```

---

### 1.7. Index design for ORDER BY

#### **Rule 1: Index column order = ORDER BY column order**
```sql
-- Query
ORDER BY status, order_date DESC

-- Good index
CREATE INDEX idx_1 ON orders(status, order_date DESC);

-- Bad index (wrong order)
CREATE INDEX idx_2 ON orders(order_date, status);
```

#### **Rule 2: Include WHERE columns**
```sql
-- Query
WHERE user_id = 123
ORDER BY order_date DESC

-- Best index: WHERE column first, then ORDER BY
CREATE INDEX idx_orders_user_date 
ON orders(user_id, order_date DESC);

-- Why: 
-- 1. Filter by user_id (selective)
-- 2. Within that user, already sorted by date
-- 3. No sort needed!
```

#### **Rule 3: ASC/DESC matters**
```sql
-- ORDER BY created_at DESC

-- Good
CREATE INDEX idx_1 ON orders(created_at DESC);

-- Also OK (PostgreSQL can scan backward)
CREATE INDEX idx_2 ON orders(created_at ASC);

-- But explicit DESC is clearer and may be faster
```

---

## 2. PRACTICE — Thực hành với PostgreSQL

### Setup: Large dataset for testing

```sql
\c ecommerce_practice;

-- Check current data
SELECT COUNT(*) FROM orders;  -- Should have ~50k

-- Add more data for pagination testing
INSERT INTO orders (user_id, order_date, total_amount, status)
SELECT 
    (random() * 9999 + 1)::int,
    CURRENT_TIMESTAMP - (random() * 730 || ' days')::interval,
    (random() * 1000)::decimal(10,2),
    CASE (random() * 4)::int
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'paid'
        WHEN 2 THEN 'shipped'
        ELSE 'delivered'
    END
FROM generate_series(1, 450000);  -- Total: ~500k orders

-- Verify
SELECT COUNT(*) FROM orders;  -- Should be ~500,000

-- Create indexes for testing
CREATE INDEX idx_orders_id ON orders(order_id);
CREATE INDEX idx_orders_date_desc ON orders(order_date DESC);
CREATE INDEX idx_orders_status_date ON orders(status, order_date DESC);

-- Enable timing
\timing on
```

---

## 3. BÀI TẬP THỰC HÀNH

### **Exercise 1: ORDER BY with/without index**

```sql
-- Test 1: ORDER BY without index
-- Drop index nếu có
DROP INDEX IF EXISTS idx_orders_amount;

EXPLAIN ANALYZE
SELECT order_id, total_amount
FROM orders
ORDER BY total_amount DESC
LIMIT 20;

-- Q: Có "Sort" trong plan không? Execution time?

-- Test 2: ORDER BY with index
CREATE INDEX idx_orders_amount ON orders(total_amount DESC);

EXPLAIN ANALYZE
SELECT order_id, total_amount
FROM orders
ORDER BY total_amount DESC
LIMIT 20;

-- Q: Còn "Sort" không? Execution time giảm bao nhiêu?
```

<details>
<summary>Đáp án</summary>

**Test 1 (no index):**
```
Plan:
Limit
  -> Sort (cost=XX..XX rows=20)
     Sort Key: total_amount DESC
     -> Seq Scan on orders (cost=XX..XX rows=500000)

Execution time: ~500-1000ms
```
- Phải đọc 500k rows
- Sort trong memory (hoặc disk nếu lớn)
- Chậm!

**Test 2 (with index):**
```
Plan:
Limit
  -> Index Scan Backward using idx_orders_amount

Execution time: <5ms
```
- Không cần Sort!
- Chỉ đọc 20 rows từ index
- Nhanh hơn 100-200x!

**Lesson:** Index loại bỏ sort, performance improvement rất lớn
</details>

---

### **Exercise 2: OFFSET pagination - Performance degradation**

```sql
-- Đo performance với OFFSET tăng dần

-- Page 1 (OFFSET 0)
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
ORDER BY order_id
LIMIT 20 OFFSET 0;

-- Page 100 (OFFSET 1980)
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
ORDER BY order_id
LIMIT 20 OFFSET 1980;

-- Page 1000 (OFFSET 19980)
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
ORDER BY order_id
LIMIT 20 OFFSET 19980;

-- Page 10000 (OFFSET 199980)
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
ORDER BY order_id
LIMIT 20 OFFSET 199980;

-- Q: So sánh execution time và rows scanned
```

<details>
<summary>Đáp án</summary>

**Results (approximate):**
```
Page 1:     Execution time: 1ms,    Rows read: ~20
Page 100:   Execution time: 5ms,    Rows read: ~2000
Page 1000:  Execution time: 50ms,   Rows read: ~20000
Page 10000: Execution time: 500ms,  Rows read: ~200000
```

**EXPLAIN ANALYZE output:**
```sql
-- Page 10000
Limit (actual time=480.123..480.145 rows=20 loops=1)
  -> Index Scan using idx_orders_id on orders 
     (actual time=0.015..450.234 rows=200000 loops=1)
```

**Observation:**
- PostgreSQL đọc 200,000 rows
- Bỏ 199,980 rows
- Chỉ trả về 20 rows
- Linear degradation: OFFSET càng lớn, càng chậm

**Lesson:** OFFSET không scalable cho pagination!
</details>

---

### **Exercise 3: Keyset Pagination - Stable Performance**

```sql
-- Implement keyset pagination

-- Page 1: Get first 20
SELECT order_id, order_date, total_amount
FROM orders
ORDER BY order_id DESC
LIMIT 20;

-- Giả sử last order_id = 499981

-- Page 2: Get next 20
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
WHERE order_id < 499981
ORDER BY order_id DESC
LIMIT 20;

-- Page 100: Simulate (last_id = 498001)
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
WHERE order_id < 498001
ORDER BY order_id DESC
LIMIT 20;

-- Page 1000: Simulate (last_id = 480001)
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
WHERE order_id < 480001
ORDER BY order_id DESC
LIMIT 20;

-- Page 10000: Simulate (last_id = 300001)
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
WHERE order_id < 300001
ORDER BY order_id DESC
LIMIT 20;

-- Q: Execution time có thay đổi khi page tăng không?
```

<details>
<summary>Đáp án</summary>

**Results:**
```
Page 1:     Execution time: 1ms,  Rows read: 20
Page 100:   Execution time: 1ms,  Rows read: 20
Page 1000:  Execution time: 1ms,  Rows read: 20
Page 10000: Execution time: 1ms,  Rows read: 20
```

**EXPLAIN output:**
```
Limit (actual time=0.015..0.025 rows=20 loops=1)
  -> Index Scan Backward using idx_orders_id on orders
     Index Cond: (order_id < 499981)
     (actual time=0.014..0.023 rows=20 loops=1)
```

**Observation:**
- STABLE performance!
- Luôn đọc đúng 20 rows
- WHERE + INDEX → direct seek
- Không có degradation

**Lesson:** Keyset pagination scales perfectly!
</details>

---

### **Exercise 4: Keyset với multiple sort columns**

```sql
-- Scenario: Sort by order_date DESC, order_id DESC

-- Create index
CREATE INDEX idx_orders_date_id 
ON orders(order_date DESC, order_id DESC);

-- Page 1
SELECT order_id, order_date, total_amount
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 20;

-- Giả sử last row: order_date='2024-06-15', order_id=123456

-- Page 2: Keyset với 2 columns
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
WHERE (order_date, order_id) < ('2024-06-15', 123456)
ORDER BY order_date DESC, order_id DESC
LIMIT 20;

-- Test performance với page lớn
-- Simulate page 1000: order_date='2023-12-01', order_id=98765
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
WHERE (order_date, order_id) < ('2023-12-01', 98765)
ORDER BY order_date DESC, order_id DESC
LIMIT 20;

-- Q: Performance có stable không?
```

<details>
<summary>Đáp án</summary>

**Tuple comparison in PostgreSQL:**
```sql
-- (order_date, order_id) < ('2024-06-15', 123456)
-- Equivalent to:
-- order_date < '2024-06-15' 
-- OR (order_date = '2024-06-15' AND order_id < 123456)
```

**Performance:**
- Stable ~1ms cho mọi page
- Index scan với composite condition
- Không có degradation

**Index requirement:**
- MUST match ORDER BY exactly
- `(order_date DESC, order_id DESC)`
- Leftmost prefix rule applies

**Lesson:** Keyset works với multiple columns, nhưng cần index đúng
</details>

---

### **Exercise 5: Pagination với WHERE filter**

```sql
-- Scenario: Pagination + filter
-- Get delivered orders, sorted by date

-- Bad: OFFSET method
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
WHERE status = 'delivered'
ORDER BY order_date DESC
LIMIT 20 OFFSET 10000;

-- Good: Keyset method
-- Page 1
SELECT order_id, order_date, total_amount
FROM orders
WHERE status = 'delivered'
ORDER BY order_date DESC
LIMIT 20;
-- Last: order_date = '2024-05-01', order_id = 234567

-- Page 2+
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
WHERE status = 'delivered'
  AND (order_date, order_id) < ('2024-05-01', 234567)
ORDER BY order_date DESC, order_id DESC
LIMIT 20;

-- Best index:
CREATE INDEX idx_orders_status_date_id 
ON orders(status, order_date DESC, order_id DESC);

-- Q: So sánh 2 methods
```

<details>
<summary>Đáp án</summary>

**OFFSET method (page 500):**
- Filter: ~125k delivered orders (25% of 500k)
- OFFSET 10000 → scan 10020 rows, bỏ 10000
- Execution time: ~100-200ms

**Keyset method (page 500):**
- Filter + keyset: direct seek
- Read: exactly 20 rows
- Execution time: ~1ms

**Best index:**
```sql
CREATE INDEX idx_orders_status_date_id 
ON orders(status, order_date DESC, order_id DESC);

-- Why this order:
-- 1. status (WHERE filter, selective)
-- 2. order_date DESC (ORDER BY + keyset)
-- 3. order_id DESC (ORDER BY tie-breaker)
```

**Lesson:** Combine WHERE filter + keyset trong index design
</details>

---

### **Exercise 6: Backward pagination (Previous page)**

```sql
-- Forward pagination: Easy
WHERE order_id < last_id
ORDER BY order_id DESC

-- Backward pagination: Tricky!
-- User clicks "Previous page"

-- Current page started at order_id = 499961
-- Want to get PREVIOUS 20 rows (499962-499981)

-- Solution: Reverse order, then reverse result
SELECT * FROM (
    SELECT order_id, order_date, total_amount
    FROM orders
    WHERE order_id > 499961
    ORDER BY order_id ASC  -- Reverse!
    LIMIT 20
) AS prev_page
ORDER BY order_id DESC;  -- Reverse back!

-- Test
EXPLAIN ANALYZE
SELECT * FROM (
    SELECT order_id, order_date, total_amount
    FROM orders
    WHERE order_id > 499961
    ORDER BY order_id ASC
    LIMIT 20
) AS prev_page
ORDER BY order_id DESC;
```

<details>
<summary>Đáp án</summary>

**How it works:**
1. Inner query: Get 20 rows AFTER current first_id, ASC order
2. Outer query: Reverse back to DESC order

**Performance:**
- Still fast (~1-2ms)
- Uses index
- No OFFSET needed

**Alternative: Track both directions**
```javascript
// Client-side state
{
  currentPage: {
    firstId: 499961,
    lastId: 499941
  }
}

// Next page
WHERE order_id < lastId
ORDER BY order_id DESC

// Previous page  
WHERE order_id > firstId
ORDER BY order_id ASC
LIMIT 20
```

**Lesson:** Keyset supports backward pagination, nhưng cần careful design
</details>

---

### **Exercise 7: Real-world API Implementation**

**Scenario:** E-commerce order list API

**Requirements:**
- Filter by status
- Sort by date (newest first)
- 20 items per page
- Support next/previous
- Performance: < 50ms

**Implementation:**

<details>
<summary>Đáp án</summary>

```sql
-- Database schema
CREATE INDEX idx_orders_api_pagination 
ON orders(status, order_date DESC, order_id DESC);

-- API endpoint: GET /api/orders?status=delivered&cursor=xxx

-- Page 1 (no cursor)
SELECT 
    order_id,
    order_date,
    total_amount,
    status
FROM orders
WHERE status = 'delivered'
ORDER BY order_date DESC, order_id DESC
LIMIT 21;  -- 21 để biết có next page không

-- Response:
{
  "data": [...20 items...],
  "pagination": {
    "nextCursor": "2024-01-15:123456",  -- order_date:order_id
    "hasNext": true  -- vì có 21 rows
  }
}

-- Page 2+ (with cursor)
-- Parse cursor: "2024-01-15:123456"
SELECT 
    order_id,
    order_date,
    total_amount,
    status
FROM orders
WHERE status = 'delivered'
  AND (order_date, order_id) < ('2024-01-15', 123456)
ORDER BY order_date DESC, order_id DESC
LIMIT 21;

-- Previous page
SELECT * FROM (
    SELECT 
        order_id,
        order_date,
        total_amount,
        status
    FROM orders
    WHERE status = 'delivered'
      AND (order_date, order_id) > ('2024-01-15', 123456)
    ORDER BY order_date ASC, order_id ASC
    LIMIT 21
) AS prev
ORDER BY order_date DESC, order_id DESC;
```

**Backend code (pseudo):**
```javascript
async function getOrders(status, cursor, direction = 'next') {
  let query = `
    SELECT order_id, order_date, total_amount, status
    FROM orders
    WHERE status = $1
  `;
  
  const params = [status];
  
  if (cursor) {
    const [date, id] = cursor.split(':');
    if (direction === 'next') {
      query += ` AND (order_date, order_id) < ($2, $3)
                 ORDER BY order_date DESC, order_id DESC`;
    } else {
      query += ` AND (order_date, order_id) > ($2, $3)
                 ORDER BY order_date ASC, order_id ASC`;
    }
    params.push(date, id);
  } else {
    query += ` ORDER BY order_date DESC, order_id DESC`;
  }
  
  query += ` LIMIT 21`;
  
  let rows = await db.query(query, params);
  
  // Reverse if backward
  if (direction === 'prev') {
    rows = rows.reverse();
  }
  
  const hasNext = rows.length > 20;
  const data = rows.slice(0, 20);
  
  return {
    data,
    pagination: {
      nextCursor: hasNext ? 
        `${data[19].order_date}:${data[19].order_id}` : null,
      prevCursor: data[0] ? 
        `${data[0].order_date}:${data[0].order_id}` : null,
      hasNext,
      hasPrev: !!cursor
    }
  };
}
```

**Performance:**
- Execution time: <5ms
- Scales to millions of rows
- No degradation with deep pagination
</details>

---

### **Exercise 8: Common mistakes**

**Identify problems trong các queries sau:**

```sql
-- Query 1
SELECT * FROM orders
ORDER BY order_date DESC
LIMIT 20 OFFSET 50000;

-- Query 2  
SELECT * FROM orders
WHERE user_id = 123
ORDER BY created_at DESC
LIMIT 20 OFFSET 100;
-- Index: (user_id, order_id)

-- Query 3
SELECT * FROM orders
ORDER BY YEAR(order_date) DESC, order_id
LIMIT 20;

-- Query 4
SELECT * FROM orders
WHERE order_id < 10000
ORDER BY order_date DESC
LIMIT 20;
-- Index: (order_id)

-- Q: Vấn đề của mỗi query? Cách fix?
```

<details>
<summary>Đáp án</summary>

**Query 1: OFFSET too large**
- Problem: OFFSET 50000 → đọc 50020 rows, bỏ 50000
- Fix: Dùng keyset pagination
```sql
-- Keyset version
WHERE (order_date, order_id) < (last_date, last_id)
ORDER BY order_date DESC, order_id DESC
LIMIT 20;
```

**Query 2: Wrong index**
- Problem: Index (user_id, order_id) không match ORDER BY created_at
- Fix: Tạo index đúng
```sql
CREATE INDEX idx_user_created 
ON orders(user_id, created_at DESC);
```

**Query 3: Function on column**
- Problem: YEAR(order_date) làm mất index, phải sort
- Fix: Rewrite hoặc computed column
```sql
-- Option 1: Don't extract year
ORDER BY order_date DESC, order_id

-- Option 2: Add computed column
ALTER TABLE orders ADD COLUMN order_year INT 
  GENERATED ALWAYS AS (EXTRACT(YEAR FROM order_date)) STORED;
CREATE INDEX idx_year_id ON orders(order_year DESC, order_id);
```

**Query 4: Index không match ORDER BY**
- Problem: WHERE dùng order_id, ORDER BY dùng order_date → không tối ưu
- Fix: Composite index
```sql
-- Better index
CREATE INDEX idx_id_date ON orders(order_id, order_date DESC);

-- Or better query design
-- Nếu filter by id, sort by id luôn
ORDER BY order_id DESC
```
</details>

---

## 4. BEST PRACTICES

### ✅ **Rule 1: Dùng Keyset Pagination, không OFFSET**
```sql
-- Bad
LIMIT 20 OFFSET 10000

-- Good  
WHERE id < last_id
ORDER BY id DESC
LIMIT 20
```

### ✅ **Rule 2: Index phải match ORDER BY**
```sql
-- Query
ORDER BY created_at DESC, id DESC

-- Index
CREATE INDEX idx ON table(created_at DESC, id DESC);
```

### ✅ **Rule 3: Include WHERE trong index**
```sql
-- Query
WHERE status = 'active'
ORDER BY created_at DESC

-- Index: WHERE column first
CREATE INDEX idx ON table(status, created_at DESC);
```

### ✅ **Rule 4: LIMIT +1 để check hasNext**
```sql
-- Request 20, query 21
SELECT ... LIMIT 21;

-- If 21 rows returned → hasNext = true
```

### ✅ **Rule 5: Stable sort order (tie-breaker)**
```sql
-- Bad: Non-unique sort
ORDER BY created_at DESC  -- Multiple rows cùng timestamp!

-- Good: Add unique column
ORDER BY created_at DESC, id DESC  -- Stable, reproducible
```

### ✅ **Rule 6: Cursor encoding**
```sql
-- Encode cursor để hide internal IDs
const cursor = Buffer.from(
  JSON.stringify({date: '2024-01-15', id: 123})
).toString('base64');

// Response: cursor = "eyJkYXRlIjoiMjAyNC0wMS0xNSIsImlkIjoxMjN9"
```

---

## 5. ANTI-PATTERNS ⚠️

### ❌ **Anti-pattern 1: Deep OFFSET**
```sql
-- NEVER do this
SELECT * FROM orders
ORDER BY id
LIMIT 20 OFFSET 100000;  -- 💀 RIP performance
```

### ❌ **Anti-pattern 2: ORDER BY without index**
```sql
-- No index on order_date
SELECT * FROM orders
ORDER BY order_date DESC
LIMIT 20;
-- → Full table scan + sort
```

### ❌ **Anti-pattern 3: SELECT * với ORDER BY**
```sql
-- Bad: Wide rows + sort = memory hog
SELECT * FROM orders
ORDER BY created_at DESC;

-- Good: Only needed columns
SELECT id, created_at, status
ORDER BY created_at DESC;
```

### ❌ **Anti-pattern 4: Function trong ORDER BY**
```sql
-- Mất index
ORDER BY DATE(created_at) DESC;

-- Đúng
ORDER BY created_at DESC;
```

### ❌ **Anti-pattern 5: Non-deterministic sort**
```sql
-- Bad: Multiple rows có cùng created_at
ORDER BY created_at DESC
LIMIT 20;
-- → Kết quả không consistent giữa các requests!

-- Good: Add tie-breaker
ORDER BY created_at DESC, id DESC;
```

---

## 6. PERFORMANCE COMPARISON

### Benchmark: 500,000 orders

| Page | OFFSET Method | Keyset Method | Speedup |
|------|---------------|---------------|---------|
| 1 | 1ms | 1ms | 1x |
| 10 | 5ms | 1ms | 5x |
| 100 | 50ms | 1ms | 50x |
| 1,000 | 500ms | 1ms | 500x |
| 10,000 | 5,000ms | 1ms | 5,000x |

**Conclusion:** Keyset pagination scales O(1), OFFSET scales O(n)

---

## 7. CHECKLIST ĐẠT TASK 05

✅ **Hiểu ORDER BY cost:**
- [ ] Biết ORDER BY cần sort (CPU + memory)
- [ ] Biết index loại bỏ sort
- [ ] Hiểu in-memory vs external sort

✅ **Pagination:**
- [ ] Hiểu vấn đề của OFFSET (walk-through)
- [ ] Implement keyset pagination
- [ ] Handle multiple sort columns

✅ **Index design:**
- [ ] Tạo index match ORDER BY
- [ ] Include WHERE columns
- [ ] ASC/DESC correct order

✅ **Production ready:**
- [ ] Implement API với keyset pagination
- [ ] Handle next/previous pages
- [ ] Cursor encoding/decoding
- [ ] Performance < 50ms cho mọi page

---

## 8. REAL-WORLD EXAMPLES

### **Example 1: Twitter/X Timeline**
```sql
-- Infinite scroll, newest first
SELECT tweet_id, content, created_at
FROM tweets
WHERE user_id IN (following_list)
  AND (created_at, tweet_id) < (cursor_date, cursor_id)
ORDER BY created_at DESC, tweet_id DESC
LIMIT 20;

-- Index:
CREATE INDEX idx_tweets_timeline 
ON tweets(user_id, created_at DESC, tweet_id DESC);
```

### **Example 2: E-commerce Product List**
```sql
-- Filter + sort by popularity
SELECT product_id, name, price, popularity_score
FROM products
WHERE category_id = 5
  AND price BETWEEN 100 AND 500
  AND (popularity_score, product_id) < (cursor_score, cursor_id)
ORDER BY popularity_score DESC, product_id DESC
LIMIT 20;

-- Index:
CREATE INDEX idx_products_category_popularity
ON products(category_id, price, popularity_score DESC, product_id DESC);
```

### **Example 3: Admin Dashboard - Order Management**
```sql
-- Complex filters + pagination
SELECT order_id, customer_name, status, created_at
FROM orders
WHERE status IN ('pending', 'processing')
  AND created_at >= '2024-01-01'
  AND (created_at, order_id) < (cursor_date, cursor_id)
ORDER BY created_at DESC, order_id DESC
LIMIT 50;

-- Index:
CREATE INDEX idx_orders_admin
ON orders(status, created_at DESC, order_id DESC)
WHERE status IN ('pending', 'processing');  -- Partial index
```

---

## 9. NEXT STEPS

Bạn đã hoàn thành Task 05 khi:
- ✅ Không dùng OFFSET cho pagination
- ✅ Implement keyset pagination cho API
- ✅ Tạo index đúng cho ORDER BY
- ✅ Performance stable cho mọi page

**→ Tiếp theo: TASK 06 — Aggregate & GROUP BY cho báo cáo doanh nghiệp**

Dashboard, KPI, báo cáo - làm sao để "đúng số" và "chạy nổi"!
