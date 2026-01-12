# TASK 03 — SELECT Tối Thiểu, Đúng Thứ Cần

> **Mục tiêu**: Giảm IO/network/memory - nền tảng của tối ưu. Viết SELECT hiệu quả và maintainable.

---

## 1. THEORY — Tại sao SELECT quan trọng?

### 1.1. SELECT ảnh hưởng đến toàn bộ pipeline

```
Disk I/O → Memory → CPU → Network → Client
   ↑         ↑        ↑       ↑        ↑
   Đọc    Cache    Process  Transfer  Render
```

**SELECT * làm gì:**
- Đọc TOÀN BỘ cột từ disk (I/O cao)
- Load toàn bộ vào memory (RAM lãng phí)
- Transfer toàn bộ qua network (bandwidth lãng phí)
- Client parse toàn bộ (CPU client lãng phí)

**SELECT specific columns làm gì:**
- Chỉ đọc cột cần (I/O thấp hơn)
- Ít memory hơn
- Ít network traffic hơn
- Client parse nhanh hơn
- **Covering index** có thể dùng (không cần access table)

---

### 1.2. SELECT * — Tội ác lớn nhất trong production

#### **Vấn đề 1: Performance**
```sql
-- BAD: 100 cột, mỗi row 10KB
SELECT * FROM users;  
-- → Đọc 10MB cho 1000 users

-- GOOD: 3 cột, mỗi row 100 bytes
SELECT user_id, username, email FROM users;
-- → Đọc 100KB cho 1000 users (gấp 100 lần nhanh hơn!)
```

#### **Vấn đề 2: Network bandwidth**
```sql
-- API endpoint: Get user list
-- Bad: Trả về 50MB data (tất cả cột)
-- Good: Trả về 500KB data (chỉ cột cần hiển thị)
-- → 100x faster response time
```

#### **Vấn đề 3: Breaking changes**
```sql
-- Dev thêm cột mới vào bảng
ALTER TABLE products ADD COLUMN internal_notes TEXT;

-- Code cũ dùng SELECT *
SELECT * FROM products;  -- Giờ trả về thêm internal_notes!
-- → API response thay đổi, frontend có thể bị lỗi
-- → Security issue: lộ dữ liệu internal

-- Code dùng explicit columns
SELECT product_id, product_name, price FROM products;
-- → Không bị ảnh hưởng, vẫn chạy ổn
```

#### **Vấn đề 4: Không dùng được Covering Index**
```sql
-- Index: CREATE INDEX idx_user_email ON users(email, username);

-- BAD: Vẫn phải access table để lấy tất cả cột
SELECT * FROM users WHERE email = 'john@example.com';

-- GOOD: Covering index! Không cần access table
SELECT email, username FROM users WHERE email = 'john@example.com';
-- → Index-only scan, nhanh gấp 10-100x
```

---

### 1.3. Projection (chọn cột) ảnh hưởng performance

#### **Wide row problem**
```sql
-- Bảng có 50 cột, mỗi row 20KB
-- products: id, name, description (TEXT 5KB), specs (JSON 10KB), 
--           images (TEXT 3KB), reviews_data (JSON 2KB), ...

-- Bad: Pagination
SELECT * FROM products 
ORDER BY created_at DESC 
LIMIT 20;
-- → Đọc 20KB × 20 = 400KB

-- Good: Chỉ lấy cột hiển thị
SELECT product_id, product_name, price, thumbnail 
FROM products 
ORDER BY created_at DESC 
LIMIT 20;
-- → Đọc 200 bytes × 20 = 4KB (gấp 100 lần nhanh hơn!)
```

#### **Aggregate với cột không cần thiết**
```sql
-- Bad
SELECT *, COUNT(*) as cnt 
FROM orders 
GROUP BY user_id;
-- Error! Phải GROUP BY tất cả cột

-- Good
SELECT user_id, COUNT(*) as order_count
FROM orders
GROUP BY user_id;
-- Nhanh, đơn giản, đúng
```

---

### 1.4. Datatype awareness (biết kiểu dữ liệu)

#### **Chọn đúng kiểu, không cast**
```sql
-- Bad: CAST mất index
SELECT * FROM orders 
WHERE DATE(created_at) = '2024-01-15';
-- → Full table scan

-- Good: Dùng đúng kiểu
SELECT order_id, user_id, total_amount 
FROM orders 
WHERE created_at >= '2024-01-15' 
  AND created_at < '2024-01-16';
-- → Dùng index, nhanh
```

#### **Không convert kiểu không cần thiết**
```sql
-- Bad
SELECT CAST(user_id AS VARCHAR) FROM users;  -- Tại sao?

-- Good
SELECT user_id FROM users;  -- Để app convert nếu cần
```

---

### 1.5. Alias — Maintainability và readability

#### **Dùng alias cho bảng khi JOIN**
```sql
-- Bad: Khó đọc
SELECT users.user_id, users.username, orders.order_id, orders.total_amount
FROM users
JOIN orders ON users.user_id = orders.user_id;

-- Good: Ngắn gọn, rõ ràng
SELECT u.user_id, u.username, o.order_id, o.total_amount
FROM users u
JOIN orders o ON u.user_id = o.user_id;
```

#### **Dùng alias cho cột khi cần rõ nghĩa**
```sql
-- Bad: Không hiểu ý nghĩa
SELECT COUNT(*), SUM(total_amount)
FROM orders;

-- Good: Rõ ràng
SELECT 
    COUNT(*) as total_orders,
    SUM(total_amount) as revenue
FROM orders;
```

#### **Alias khi có aggregate/expression**
```sql
-- Bad: Client phải đọc "?column?"
SELECT 
    user_id,
    COUNT(*),
    SUM(quantity * unit_price)
FROM order_items
GROUP BY user_id;

-- Good
SELECT 
    user_id,
    COUNT(*) as total_items,
    SUM(quantity * unit_price) as total_spent
FROM order_items
GROUP BY user_id;
```

---

## 2. BEST PRACTICES

### ✅ **Rule 1: Chỉ SELECT cột bạn cần dùng**
```sql
-- For API response
SELECT user_id, username, email, created_at
FROM users;

-- For internal processing
SELECT user_id
FROM users 
WHERE status = 'active';
```

### ✅ **Rule 2: Tránh SELECT * trừ khi debug**
```sql
-- Debug: OK
SELECT * FROM users WHERE user_id = 123;

-- Production code: NO
SELECT * FROM users;
```

### ✅ **Rule 3: Dùng alias có ý nghĩa**
```sql
SELECT 
    u.user_id,
    u.username,
    COUNT(o.order_id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as lifetime_value
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username;
```

### ✅ **Rule 4: Chọn đúng cột cho index coverage**
```sql
-- Index: (user_id, created_at, status)
SELECT user_id, created_at, status
FROM orders
WHERE user_id = 123
ORDER BY created_at DESC;
-- → Covering index, chỉ đọc index
```

### ✅ **Rule 5: Projection trong subquery/CTE**
```sql
-- Bad: Subquery trả về tất cả cột
SELECT * 
FROM (
    SELECT * FROM orders WHERE status = 'paid'
) paid_orders;

-- Good: Chỉ lấy cột cần
SELECT order_id, user_id, total_amount
FROM (
    SELECT order_id, user_id, total_amount, status 
    FROM orders 
    WHERE status = 'paid'
) paid_orders;
```

---

## 3. PRACTICE — Thực hành với PostgreSQL

### Setup: Tiếp tục từ Task 02

```sql
-- Nếu chưa có database, chạy lại setup từ Task 02
-- Hoặc kết nối vào database đã tạo:
\c ecommerce_practice;

-- Tạo thêm dữ liệu lớn hơn để test performance
-- Insert 10,000 users
INSERT INTO users (username, email)
SELECT 
    'user_' || i,
    'user' || i || '@example.com'
FROM generate_series(5, 10000) i;

-- Insert 50,000 orders
INSERT INTO orders (user_id, order_date, total_amount, status)
SELECT 
    (random() * 9999 + 1)::int,
    CURRENT_TIMESTAMP - (random() * 365 || ' days')::interval,
    (random() * 1000)::decimal(10,2),
    CASE (random() * 3)::int
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'paid'
        WHEN 2 THEN 'shipped'
        ELSE 'delivered'
    END
FROM generate_series(1, 50000);

-- Insert 200,000 order_items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT 
    (random() * 50000 + 1)::int,
    (random() * 7 + 1)::int,
    (random() * 5 + 1)::int,
    (random() * 500)::decimal(10,2)
FROM generate_series(1, 200000);

-- Tạo index để test
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_date ON orders(order_date);
```

---

## 4. BÀI TẬP THỰC HÀNH

### **Exercise 1: So sánh SELECT * vs SELECT columns**

```sql
-- Q1: Đo thời gian và kích thước kết quả
-- Version A: SELECT *
EXPLAIN ANALYZE
SELECT * FROM orders LIMIT 1000;

-- Version B: SELECT specific
EXPLAIN ANALYZE
SELECT order_id, user_id, status FROM orders LIMIT 1000;
```

**Bài tập:**
1. Chạy cả 2 queries và so sánh "Execution Time"
2. So sánh kích thước kết quả (số bytes transfer)
3. Giải thích tại sao version B nhanh hơn

<details>
<summary>Đáp án</summary>

**Kết quả mong đợi:**
- Version B nhanh hơn 2-3x (tùy số cột trong bảng)
- Version B ít bytes transfer hơn (ít cột)
- Version B có thể dùng index-only scan nếu có covering index

**Giải thích:**
- SELECT * phải đọc tất cả cột từ heap
- SELECT specific chỉ đọc cột cần, ít I/O hơn
- PostgreSQL phải deserialize ít data hơn
</details>

---

### **Exercise 2: Covering Index magic**

```sql
-- Tạo covering index
CREATE INDEX idx_orders_covering 
ON orders(user_id, status, order_date);

-- Q1: Query không covering
EXPLAIN ANALYZE
SELECT order_id, user_id, status, total_amount
FROM orders
WHERE user_id = 100;

-- Q2: Query có covering
EXPLAIN ANALYZE
SELECT user_id, status, order_date
FROM orders
WHERE user_id = 100;
```

**Câu hỏi:**
1. Query nào dùng "Index Only Scan"?
2. Query nào phải "Index Scan" + access heap?
3. So sánh execution time

<details>
<summary>Đáp án</summary>

**Q2 dùng Index Only Scan:**
- Tất cả cột cần (user_id, status, order_date) đều có trong index
- PostgreSQL không cần access table heap
- Nhanh hơn 5-10x

**Q1 phải Index Scan + heap access:**
- Cần order_id và total_amount không có trong index
- Phải access table để lấy cột này
- Chậm hơn vì thêm I/O

**Lesson:** Chọn đúng cột trong SELECT → có thể dùng covering index
</details>

---

### **Exercise 3: Wide row problem**

```sql
-- Tạo bảng wide row
CREATE TABLE product_details (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(200),
    short_desc TEXT,
    full_description TEXT,  -- 5KB average
    specifications JSON,    -- 10KB average
    user_manual TEXT,       -- 20KB average
    reviews_data JSON,      -- 5KB average
    metadata JSON           -- 5KB average
);

-- Insert sample data (simulated wide rows)
INSERT INTO product_details (name, short_desc, full_description)
SELECT 
    'Product ' || i,
    'Short description for product ' || i,
    repeat('Long description text. ', 500)  -- ~10KB
FROM generate_series(1, 1000) i;

-- Q1: SELECT * (bad)
EXPLAIN ANALYZE
SELECT * FROM product_details LIMIT 10;

-- Q2: SELECT only needed columns (good)
EXPLAIN ANALYZE
SELECT product_id, name, short_desc FROM product_details LIMIT 10;
```

**Bài tập:**
1. So sánh "Execution Time" và "Planning Time"
2. Ước tính kích thước data transfer (theo EXPLAIN)
3. Nếu đây là API endpoint, response time sẽ khác nhau như thế nào?

<details>
<summary>Đáp án</summary>

**Q1 (SELECT *):**
- Đọc ~100KB cho 10 rows (nếu mỗi row ~10KB)
- Execution time: ~5-10ms (với SSD)
- Network transfer: 100KB
- Client parsing: chậm

**Q2 (SELECT specific):**
- Đọc ~2KB cho 10 rows
- Execution time: ~0.5-1ms
- Network transfer: 2KB
- Client parsing: nhanh

**API impact:**
- Q1: 100ms+ response (network + parsing)
- Q2: 10ms response (50x nhanh hơn!)
</details>

---

### **Exercise 4: Alias cho maintainability**

**Scenario:** Tạo báo cáo user spending

```sql
-- Version 1: Không alias (bad)
SELECT 
    users.user_id,
    users.username,
    COUNT(orders.order_id),
    SUM(orders.total_amount),
    AVG(orders.total_amount),
    MAX(orders.order_date)
FROM users
LEFT JOIN orders ON users.user_id = orders.user_id
WHERE orders.status = 'paid'
GROUP BY users.user_id, users.username;

-- Version 2: Có alias (good)
SELECT 
    u.user_id,
    u.username,
    COUNT(o.order_id) as total_paid_orders,
    COALESCE(SUM(o.total_amount), 0) as total_revenue,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id AND o.status = 'paid'
GROUP BY u.user_id, u.username;
```

**Câu hỏi:**
1. Version nào dễ đọc hơn?
2. Version nào dễ maintain hơn khi có yêu cầu mới?
3. Có bug nào trong Version 1 không?

<details>
<summary>Đáp án</summary>

**Version 2 tốt hơn:**
- Alias bảng (u, o) ngắn gọn, dễ đọc
- Alias cột rõ nghĩa (total_paid_orders thay vì count)
- COALESCE xử lý NULL cho users không có order

**Bug trong Version 1:**
- WHERE orders.status = 'paid' biến LEFT JOIN → INNER JOIN
- Users không có orders bị mất
- Nên đặt filter vào ON clause hoặc dùng COALESCE

**Maintainability:**
- Version 2: Thêm cột mới dễ dàng, biết ngay ý nghĩa
- Version 1: Khó hiểu output columns (count? count của gì?)
</details>

---

### **Exercise 5: Projection trong subquery**

**Scenario:** Lấy top 100 users có orders nhiều nhất

```sql
-- Bad: Subquery lấy tất cả cột
SELECT *
FROM (
    SELECT 
        users.*,
        COUNT(orders.order_id) as order_count
    FROM users
    LEFT JOIN orders ON users.user_id = orders.user_id
    GROUP BY users.user_id
) user_stats
ORDER BY order_count DESC
LIMIT 100;

-- Good: Chỉ lấy cột cần
SELECT 
    user_id,
    username,
    email,
    order_count
FROM (
    SELECT 
        u.user_id,
        u.username,
        u.email,
        COUNT(o.order_id) as order_count
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.username, u.email
) user_stats
ORDER BY order_count DESC
LIMIT 100;
```

**Bài tập:**
1. Chạy EXPLAIN ANALYZE cho cả 2 queries
2. So sánh execution time
3. Viết lại bằng CTE

<details>
<summary>Đáp án</summary>

**Performance:**
- Version 2 nhanh hơn vì ít cột trong GROUP BY
- Ít memory cho sorting
- Ít data transfer

**CTE version:**
```sql
WITH user_stats AS (
    SELECT 
        u.user_id,
        u.username,
        u.email,
        COUNT(o.order_id) as order_count
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.username, u.email
)
SELECT 
    user_id,
    username,
    email,
    order_count
FROM user_stats
ORDER BY order_count DESC
LIMIT 100;
```
</details>

---

### **Exercise 6: Thực chiến API endpoint**

**Scenario:** Tạo API endpoint "Get product list for homepage"

**Yêu cầu:**
- Hiển thị 20 sản phẩm mới nhất
- Chỉ cần: id, name, price, thumbnail (không cần description, specs, reviews...)
- Phải nhanh (<50ms)

```sql
-- Your task: Viết query tối ưu
-- Hint: Chọn đúng cột, dùng index, LIMIT

-- Test data
ALTER TABLE products ADD COLUMN thumbnail VARCHAR(200);
UPDATE products SET thumbnail = 'https://cdn.example.com/product_' || product_id || '.jpg';
```

<details>
<summary>Đáp án</summary>

```sql
-- Optimal query
SELECT 
    product_id,
    product_name,
    price,
    thumbnail
FROM products
ORDER BY product_id DESC  -- Giả sử product_id tăng dần theo thời gian
LIMIT 20;

-- Hoặc nếu có created_at:
-- CREATE INDEX idx_products_created ON products(created_at DESC);

SELECT 
    product_id,
    product_name,
    price,
    thumbnail
FROM products
ORDER BY product_id DESC  -- PK đã có index
LIMIT 20;

-- Why fast:
-- 1. Chỉ 4 cột (ít I/O)
-- 2. LIMIT 20 (ít rows)
-- 3. ORDER BY PK (dùng index, không cần sort)
-- 4. Không JOIN (simple query)
```

**Performance expectation:**
- Execution time: < 1ms
- Total response time: < 10ms
</details>

---

### **Exercise 7: Debug slow query**

**Scenario:** Query này chậm, tìm và sửa

```sql
-- Slow query (customer complains)
SELECT *
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'delivered'
ORDER BY o.order_date DESC
LIMIT 100;
```

**Bài tập:**
1. Chạy EXPLAIN ANALYZE, tìm bottleneck
2. Liệt kê tất cả vấn đề
3. Viết lại query tối ưu

<details>
<summary>Đáp án</summary>

**Vấn đề:**
1. **SELECT ***: Lấy tất cả cột từ 4 bảng (lãng phí)
2. **Wide result set**: Mỗi order × nhiều order_items = row multiplication
3. **No covering index**: ORDER BY + filter không tối ưu

**Query tối ưu:**
```sql
-- Version 1: Nếu cần list orders (không cần items)
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    u.username,
    u.email
FROM orders o
JOIN users u ON o.user_id = u.user_id
WHERE o.status = 'delivered'
ORDER BY o.order_date DESC
LIMIT 100;

-- Version 2: Nếu cần cả items
WITH delivered_orders AS (
    SELECT 
        o.order_id,
        o.order_date,
        o.total_amount,
        u.username
    FROM orders o
    JOIN users u ON o.user_id = u.user_id
    WHERE o.status = 'delivered'
    ORDER BY o.order_date DESC
    LIMIT 100
)
SELECT 
    do.order_id,
    do.order_date,
    do.total_amount,
    do.username,
    oi.product_id,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM delivered_orders do
JOIN order_items oi ON do.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY do.order_date DESC, oi.order_item_id;

-- Index needed:
CREATE INDEX idx_orders_status_date ON orders(status, order_date DESC);
```

**Why faster:**
- Version 1: 100x nhanh hơn (no items join)
- Version 2: LIMIT trước, JOIN sau (ít rows)
- Specific columns only (ít I/O)
</details>

---

## 5. PERFORMANCE MEASUREMENT

### Tool: pg_stat_statements (PostgreSQL extension)

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Reset stats
SELECT pg_stat_statements_reset();

-- Run your queries...

-- Check top slow queries
SELECT 
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

---

## 6. CHECKLIST ĐẠT TASK 03

✅ **Hiểu SELECT impact:**
- [ ] Biết SELECT * ảnh hưởng performance như thế nào
- [ ] Hiểu I/O, memory, network, CPU pipeline
- [ ] Biết covering index là gì và tại sao quan trọng

✅ **Viết SELECT đúng:**
- [ ] Chỉ chọn cột cần thiết
- [ ] Tránh SELECT * trong production code
- [ ] Dùng alias có ý nghĩa

✅ **Tối ưu performance:**
- [ ] Biết projection ảnh hưởng performance
- [ ] Chọn cột để tận dụng covering index
- [ ] Hiểu wide row problem

✅ **Maintainability:**
- [ ] Dùng alias cho bảng khi JOIN
- [ ] Dùng alias cho cột khi aggregate/expression
- [ ] Code dễ đọc, dễ maintain

✅ **Thực hành:**
- [ ] So sánh được SELECT * vs SELECT specific
- [ ] Dùng EXPLAIN ANALYZE để đo performance
- [ ] Debug và fix slow queries

---

## 7. ANTI-PATTERNS ⚠️

### ❌ **Anti-pattern 1: SELECT * everywhere**
```sql
-- Bad
SELECT * FROM orders WHERE user_id = 123;

-- Good
SELECT order_id, order_date, status, total_amount 
FROM orders 
WHERE user_id = 123;
```

### ❌ **Anti-pattern 2: No alias in complex queries**
```sql
-- Bad: Khó đọc
SELECT users.username, COUNT(orders.order_id)
FROM users
JOIN orders ON users.user_id = orders.user_id
GROUP BY users.user_id, users.username;

-- Good
SELECT u.username, COUNT(o.order_id) as order_count
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username;
```

### ❌ **Anti-pattern 3: Aggregate without alias**
```sql
-- Bad: Client nhận "?column?"
SELECT user_id, COUNT(*), SUM(total_amount)
FROM orders
GROUP BY user_id;

-- Good
SELECT 
    user_id,
    COUNT(*) as order_count,
    SUM(total_amount) as total_spent
FROM orders
GROUP BY user_id;
```

---

## 8. REAL-WORLD SCENARIOS

### **Scenario 1: API pagination**
```sql
-- Bad: Wide rows
SELECT * FROM products 
ORDER BY created_at DESC 
LIMIT 20 OFFSET 0;

-- Good: Narrow projection
SELECT product_id, product_name, price, thumbnail
FROM products
ORDER BY product_id DESC  -- PK index
LIMIT 20;
```

### **Scenario 2: Dashboard KPI**
```sql
-- Bad: No alias
SELECT 
    COUNT(*),
    SUM(total_amount),
    AVG(total_amount)
FROM orders
WHERE status = 'delivered';

-- Good: Clear meaning
SELECT 
    COUNT(*) as total_delivered_orders,
    SUM(total_amount) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_order_value
FROM orders
WHERE status = 'delivered';
```

### **Scenario 3: Export to CSV**
```sql
-- Bad: Export tất cả (lộ dữ liệu sensitive)
SELECT * FROM users;

-- Good: Chỉ export cột cần thiết
SELECT user_id, username, email, created_at
FROM users
WHERE status = 'active';
```

---

## 9. NEXT STEPS

Bạn đã hoàn thành Task 03 khi:
- ✅ Không còn dùng SELECT * trong code production
- ✅ Biết chọn cột để tối ưu I/O và covering index
- ✅ Dùng alias để code dễ đọc và maintain
- ✅ Đo được performance với EXPLAIN ANALYZE

**→ Tiếp theo: TASK 04 — WHERE chuẩn: lọc đúng, lọc sớm**

Filter sớm = giảm data trước khi JOIN/aggregate = nhanh hơn rất nhiều!
