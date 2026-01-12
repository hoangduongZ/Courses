# TASK 04 — WHERE Chuẩn: Lọc Đúng, Lọc Sớm

> **Mục tiêu**: Filter sớm để giảm số row trước khi JOIN/aggregate → nhanh hơn rõ rệt.

---

## 1. THEORY — Nguyên lý "Filter Early, Filter Often"

### 1.1. WHERE trong execution pipeline

```
Query Execution Flow:
┌─────────────────────────────────────────────────┐
│ 1. FROM/JOIN    → Lấy tất cả rows từ bảng      │
│ 2. WHERE        → LỌC rows (quan trọng nhất!)  │
│ 3. GROUP BY     → Nhóm rows                     │
│ 4. HAVING       → Lọc groups                    │
│ 5. SELECT       → Chọn cột                      │
│ 6. ORDER BY     → Sắp xếp                       │
│ 7. LIMIT/OFFSET → Giới hạn kết quả             │
└─────────────────────────────────────────────────┘
```

**Tại sao WHERE quan trọng:**
- Chạy SỚM trong pipeline → giảm data cho bước sau
- Có thể dùng INDEX → tránh full table scan
- Giảm memory cho JOIN/GROUP BY/ORDER BY

**Ví dụ:**
```sql
-- 1 triệu orders
-- 900k orders có status = 'delivered'

-- Bad: JOIN trước, filter sau (xử lý 1M rows)
SELECT u.username, COUNT(*)
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.status = 'delivered'
GROUP BY u.username;

-- Good: Filter sớm (chỉ xử lý 100k rows)
SELECT u.username, COUNT(*)
FROM users u
JOIN (
    SELECT user_id 
    FROM orders 
    WHERE status = 'delivered'  -- Filter TRƯỚC JOIN
) o ON u.user_id = o.user_id
GROUP BY u.username;
```

---

### 1.2. AND/OR/NOT - Precedence và Optimization

#### **Thứ tự ưu tiên (Precedence)**
```
1. NOT (cao nhất)
2. AND
3. OR (thấp nhất)
```

**Ví dụ dễ nhầm:**
```sql
-- Query này có nghĩa gì?
SELECT * FROM products
WHERE category_id = 1 OR category_id = 2 AND price > 100;

-- PostgreSQL hiểu là:
-- category_id = 1 OR (category_id = 2 AND price > 100)

-- Bạn muốn:
-- (category_id = 1 OR category_id = 2) AND price > 100

-- LUÔN dùng () để rõ ràng!
SELECT * FROM products
WHERE (category_id = 1 OR category_id = 2) 
  AND price > 100;
```

#### **AND - Tất cả điều kiện phải đúng**
```sql
-- Lấy orders: delivered + tổng tiền > 100 + năm 2024
SELECT * FROM orders
WHERE status = 'delivered'
  AND total_amount > 100
  AND order_date >= '2024-01-01'
  AND order_date < '2025-01-01';
```

**Optimization tip:** Đặt điều kiện **loại bỏ nhiều row nhất** lên TRƯỚC
```sql
-- Bad: Kiểm tra 1M rows với status, rồi mới lọc date
WHERE order_date >= '2024-01-01'  -- 100k rows
  AND status = 'delivered'         -- 10k rows

-- Good: Lọc date trước (nếu có index)
WHERE order_date >= '2024-01-01'  -- Index scan → 100k rows
  AND status = 'delivered'         -- Filter → 10k rows
```

#### **OR - Một trong các điều kiện đúng**
```sql
-- Lấy orders: pending HOẶC processing
SELECT * FROM orders
WHERE status = 'pending' 
   OR status = 'processing';

-- Tốt hơn: Dùng IN (dễ đọc, dễ optimize)
SELECT * FROM orders
WHERE status IN ('pending', 'processing');
```

**⚠️ OR làm mất index nếu dùng sai:**
```sql
-- BAD: Không dùng được index
WHERE user_id = 123 OR total_amount > 1000;
-- → Full table scan (2 điều kiện khác cột)

-- GOOD: Tách thành 2 queries + UNION nếu cần performance
SELECT * FROM orders WHERE user_id = 123
UNION
SELECT * FROM orders WHERE total_amount > 1000;
```

#### **NOT - Phủ định (cẩn thận với NULL)**
```sql
-- Tìm products KHÔNG có category_id = 1
SELECT * FROM products
WHERE NOT (category_id = 1);

-- Hoặc:
WHERE category_id != 1;
WHERE category_id <> 1;

-- ⚠️ CHÚ Ý: NULL sẽ bị loại bỏ!
-- category_id = NULL sẽ KHÔNG match
-- Nếu muốn giữ NULL:
WHERE category_id IS NULL OR category_id != 1;
```

---

### 1.3. IN / BETWEEN / IS NULL

#### **IN - Membership test**
```sql
-- Lấy products thuộc category 1, 2, 3
SELECT * FROM products
WHERE category_id IN (1, 2, 3);

-- Tương đương:
WHERE category_id = 1 
   OR category_id = 2 
   OR category_id = 3;
```

**Performance:**
- IN với ít giá trị (< 1000): OK, dùng index
- IN với nhiều giá trị (> 10000): chậm, cân nhắc JOIN với temp table

**⚠️ IN với NULL - Bẫy lớn:**
```sql
-- Có NULL trong list
SELECT * FROM products
WHERE category_id IN (1, 2, NULL);
-- Chỉ match 1, 2. NULL không bao giờ match!

-- NOT IN với NULL
SELECT * FROM products
WHERE category_id NOT IN (1, 2, NULL);
-- Kết quả: RỖNG! (vì NULL làm hỏng logic)

-- ĐÚNG: Loại NULL trước
WHERE category_id NOT IN (
    SELECT category_id 
    FROM categories 
    WHERE category_id IS NOT NULL
);
```

#### **BETWEEN - Range query**
```sql
-- Lấy orders từ 2024-01-01 đến 2024-12-31
SELECT * FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';

-- Tương đương:
WHERE order_date >= '2024-01-01' 
  AND order_date <= '2024-12-31';  -- CHÚ Ý: <=

-- ⚠️ BETWEEN bao gồm cả 2 đầu (inclusive)
```

**⚠️ Cẩn thận với TIMESTAMP:**
```sql
-- SAI: Thiếu orders lúc 23:59:59
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';
-- order_date = '2024-01-31 23:59:59' → MATCH

-- ĐÚNG: Dùng < ngày hôm sau
WHERE order_date >= '2024-01-01' 
  AND order_date < '2024-02-01';
```

#### **IS NULL / IS NOT NULL**
```sql
-- Tìm products chưa có category
SELECT * FROM products
WHERE category_id IS NULL;

-- ⚠️ SAI:
WHERE category_id = NULL;   -- Luôn false!
WHERE category_id != NULL;  -- Luôn false!

-- Tìm orders đã ship
SELECT * FROM orders
WHERE shipped_date IS NOT NULL;
```

**NULL trong composite conditions:**
```sql
-- Tìm products: category = 1 HOẶC không có category
WHERE category_id = 1 OR category_id IS NULL;

-- Tìm products: có category VÀ price > 100
WHERE category_id IS NOT NULL AND price > 100;
```

---

### 1.4. LIKE và Wildcard - Performance killer

#### **LIKE patterns**
```sql
-- Starts with (có thể dùng index)
WHERE product_name LIKE 'iPhone%';

-- Ends with (KHÔNG dùng được index)
WHERE product_name LIKE '%Pro';

-- Contains (KHÔNG dùng được index - CHẬM!)
WHERE product_name LIKE '%MacBook%';

-- Exact match (dùng = thay vì LIKE)
WHERE product_name = 'iPhone 15';  -- Nhanh hơn LIKE
```

#### **Performance comparison**
```sql
-- 1 triệu products

-- FAST: Leading wildcard, dùng index (< 1ms)
WHERE product_name LIKE 'iPhone%';

-- SLOW: Trailing wildcard, full scan (500ms+)
WHERE product_name LIKE '%Pro';

-- VERY SLOW: Both sides wildcard, full scan (1000ms+)
WHERE product_name LIKE '%MacBook%';
```

#### **Giải pháp cho full-text search**
```sql
-- Option 1: Full-text search index (PostgreSQL)
CREATE INDEX idx_product_name_fts ON products 
USING gin(to_tsvector('english', product_name));

SELECT * FROM products
WHERE to_tsvector('english', product_name) @@ to_tsquery('MacBook');

-- Option 2: Trigram index (pg_trgm)
CREATE EXTENSION pg_trgm;
CREATE INDEX idx_product_name_trgm ON products 
USING gin(product_name gin_trgm_ops);

SELECT * FROM products
WHERE product_name ILIKE '%MacBook%';  -- Dùng được index!

-- Option 3: External search engine (Elasticsearch)
-- Cho use-case search phức tạp
```

#### **Case sensitivity**
```sql
-- Case-sensitive (default)
WHERE username LIKE 'John%';  -- Match: John, Johnny

-- Case-insensitive (PostgreSQL)
WHERE username ILIKE 'john%';  -- Match: john, John, JOHN

-- Hoặc:
WHERE LOWER(username) LIKE 'john%';  -- ⚠️ Mất index!
```

---

### 1.5. Function trên cột - Sát thủ Index

#### **Vấn đề: Function làm mất index**
```sql
-- Index: CREATE INDEX idx_created ON orders(created_at);

-- BAD: Function trên indexed column → Full scan
WHERE DATE(created_at) = '2024-01-15';          -- Mất index
WHERE YEAR(created_at) = 2024;                  -- Mất index
WHERE UPPER(username) = 'JOHN';                 -- Mất index
WHERE user_id + 10 = 133;                       -- Mất index

-- GOOD: Giữ cột ở left-hand side, dùng index
WHERE created_at >= '2024-01-15' 
  AND created_at < '2024-01-16';                -- Dùng index!

WHERE created_at >= '2024-01-01' 
  AND created_at < '2025-01-01';                -- Dùng index!

WHERE username = 'john';                        -- Dùng index!

WHERE user_id = 123;                            -- Dùng index!
```

#### **Tại sao mất index?**
```
Query: WHERE DATE(created_at) = '2024-01-15'

PostgreSQL phải:
1. Đọc TOÀN BỘ rows từ table
2. Với mỗi row: tính DATE(created_at)
3. So sánh với '2024-01-15'

→ Full table scan, index vô dụng!
```

#### **Solutions**

**1. Rewrite condition**
```sql
-- Bad
WHERE DATE(order_date) = '2024-01-15';

-- Good
WHERE order_date >= '2024-01-15' 
  AND order_date < '2024-01-16';
```

**2. Function-based index (nếu thực sự cần)**
```sql
-- Tạo index trên computed value
CREATE INDEX idx_order_date_only ON orders(DATE(order_date));

-- Giờ query này dùng được index
SELECT * FROM orders
WHERE DATE(order_date) = '2024-01-15';

-- Nhưng cẩn thận: index lớn hơn, maintain cost cao hơn
```

**3. Denormalize (computed column)**
```sql
-- Thêm cột để lưu computed value
ALTER TABLE orders ADD COLUMN order_date_only DATE;
UPDATE orders SET order_date_only = DATE(order_date);

-- Trigger để auto-update
CREATE TRIGGER trg_order_date_only
BEFORE INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_order_date_only();

-- Index trên cột mới
CREATE INDEX idx_order_date_only ON orders(order_date_only);

-- Query nhanh
WHERE order_date_only = '2024-01-15';
```

---

### 1.6. Datatype mismatch - Ngầm cast

```sql
-- user_id type: INTEGER
-- Index: CREATE INDEX idx_user ON orders(user_id);

-- BAD: String vs Integer → implicit cast → mất index
WHERE user_id = '123';  -- PostgreSQL cast thành: WHERE user_id::text = '123'

-- GOOD: Đúng type
WHERE user_id = 123;

-- BAD: Decimal vs Integer
WHERE quantity = 5.0;  -- Nếu quantity là INTEGER

-- GOOD
WHERE quantity = 5;
```

**Rule:** Luôn dùng đúng datatype, tránh implicit casting

---

## 2. PRACTICE — Thực hành với PostgreSQL

### Setup: Tiếp tục database từ Task 02, 03

```sql
-- Connect
\c ecommerce_practice;

-- Check data
SELECT COUNT(*) FROM users;       -- ~10,000
SELECT COUNT(*) FROM orders;      -- ~50,000
SELECT COUNT(*) FROM order_items; -- ~200,000

-- Tạo thêm index để test
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_amount ON orders(total_amount);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_category ON products(category_id);

-- Enable timing
\timing on
```

---

## 3. BÀI TẬP THỰC HÀNH

### **Exercise 1: AND/OR Precedence**

```sql
-- Q1: Query này lấy gì?
SELECT COUNT(*) FROM orders
WHERE status = 'delivered' 
   OR status = 'shipped' 
  AND total_amount > 100;

-- Q2: Viết lại với () để rõ ý nghĩa
-- Case A: (delivered hoặc shipped) VÀ amount > 100
-- Case B: delivered HOẶC (shipped VÀ amount > 100)
```

<details>
<summary>Đáp án</summary>

```sql
-- Q1: PostgreSQL hiểu là Case B
-- status = 'delivered' OR (status = 'shipped' AND total_amount > 100)

-- Case A (nếu bạn muốn):
SELECT COUNT(*) FROM orders
WHERE (status = 'delivered' OR status = 'shipped')
  AND total_amount > 100;

-- Case B (như query gốc):
SELECT COUNT(*) FROM orders
WHERE status = 'delivered' 
   OR (status = 'shipped' AND total_amount > 100);

-- Lesson: LUÔN dùng () để rõ ràng!
```
</details>

---

### **Exercise 2: IN vs OR - Performance**

```sql
-- Test 1: OR
EXPLAIN ANALYZE
SELECT * FROM products
WHERE category_id = 1 
   OR category_id = 2 
   OR category_id = 3;

-- Test 2: IN
EXPLAIN ANALYZE
SELECT * FROM products
WHERE category_id IN (1, 2, 3);

-- Q: Cái nào nhanh hơn? Tại sao?
```

<details>
<summary>Đáp án</summary>

**Kết quả:** Gần như GIỐNG NHAU
- PostgreSQL optimizer thông minh, convert OR → IN
- Cả 2 đều dùng index scan
- IN dễ đọc hơn, nên ưu tiên dùng IN

**Execution plan giống nhau:**
```
Index Scan using idx_products_category on products
  Index Cond: (category_id = ANY ('{1,2,3}'::integer[]))
```

**Khi nào OR chậm hơn:**
```sql
-- OR trên 2 cột khác nhau → không dùng được 1 index
WHERE category_id = 1 OR price > 100;  -- Full scan hoặc Bitmap

-- IN vẫn dùng được index
WHERE category_id IN (1, 2, 3);  -- Index scan
```
</details>

---

### **Exercise 3: LIKE Performance - The Horror**

```sql
-- Tạo large dataset
INSERT INTO products (product_name, category_id, price)
SELECT 
    'Product ' || i || ' ' || 
    CASE (i % 5)
        WHEN 0 THEN 'iPhone'
        WHEN 1 THEN 'MacBook'
        WHEN 2 THEN 'iPad'
        WHEN 3 THEN 'Samsung'
        ELSE 'Dell'
    END,
    (i % 6) + 1,
    (random() * 1000)::decimal(10,2)
FROM generate_series(8, 100000) i;

-- Test 1: Leading wildcard (FAST)
EXPLAIN ANALYZE
SELECT COUNT(*) FROM products
WHERE product_name LIKE 'iPhone%';

-- Test 2: Trailing wildcard (SLOW)
EXPLAIN ANALYZE
SELECT COUNT(*) FROM products
WHERE product_name LIKE '%Pro';

-- Test 3: Both sides (VERY SLOW)
EXPLAIN ANALYZE
SELECT COUNT(*) FROM products
WHERE product_name LIKE '%MacBook%';

-- Q: So sánh execution time và explain plan
```

<details>
<summary>Đáp án</summary>

**Test 1: Leading wildcard**
- Execution time: ~1-5ms
- Plan: Index Scan (nếu có index on product_name)
- Rows scanned: Chỉ rows bắt đầu với "iPhone"

**Test 2 & 3: Trailing/Both sides wildcard**
- Execution time: ~100-500ms (với 100k rows)
- Plan: Seq Scan (Full table scan)
- Rows scanned: TẤT CẢ 100k rows

**Giải pháp:**
```sql
-- Tạo trigram index
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_product_name_trgm ON products 
USING gin(product_name gin_trgm_ops);

-- Giờ Test 3 nhanh hơn (vẫn chậm hơn Test 1)
EXPLAIN ANALYZE
SELECT COUNT(*) FROM products
WHERE product_name LIKE '%MacBook%';
-- Execution time: ~10-50ms (nhanh hơn 10x)
```
</details>

---

### **Exercise 4: Function kills Index**

```sql
-- Test performance difference

-- Test 1: Function on indexed column (BAD)
EXPLAIN ANALYZE
SELECT COUNT(*) FROM orders
WHERE DATE(order_date) = '2024-01-15';

-- Test 2: Range query (GOOD)
EXPLAIN ANALYZE
SELECT COUNT(*) FROM orders
WHERE order_date >= '2024-01-15'
  AND order_date < '2024-01-16';

-- Q1: So sánh execution time
-- Q2: So sánh explain plan (Seq Scan vs Index Scan)
```

<details>
<summary>Đáp án</summary>

**Test 1: DATE(order_date)**
- Plan: **Seq Scan** on orders
- Filter: (date(order_date) = '2024-01-15'::date)
- Execution time: ~50-100ms
- Rows scanned: ALL 50,000 rows

**Test 2: Range query**
- Plan: **Index Scan** using idx_orders_date
- Index Cond: (order_date >= ... AND order_date < ...)
- Execution time: ~0.5-2ms
- Rows scanned: Chỉ rows match (~100-500)

**Speed up: 50-100x faster!**

**Lesson:**
- Giữ indexed column ở left-hand side
- Không dùng function trên indexed column
- Rewrite thành range query
</details>

---

### **Exercise 5: NULL handling**

```sql
-- Q1: Tìm orders chưa shipped (shipped_date = NULL)
SELECT COUNT(*) FROM orders
WHERE shipped_date IS NULL;

-- Q2: Tìm orders đã shipped
SELECT COUNT(*) FROM orders
WHERE shipped_date IS NOT NULL;

-- Q3: Tìm order_items không có discount
SELECT COUNT(*) FROM order_items
WHERE discount IS NULL;

-- Q4: Tính tổng discount (chú ý NULL!)
SELECT 
    COUNT(*) as total_items,
    COUNT(discount) as items_with_discount,
    SUM(discount) as total_discount,
    SUM(COALESCE(discount, 0)) as total_discount_safe
FROM order_items;

-- Q5: NOT IN với NULL - BẪY!
-- Tìm products KHÔNG thuộc categories 1, 2, NULL
SELECT COUNT(*) FROM products
WHERE category_id NOT IN (1, 2, NULL);

-- Q: Kết quả là gì? Tại sao?
```

<details>
<summary>Đáp án</summary>

**Q1-Q4:** Straightforward

**Q5: BẪY NULL!**
```sql
-- Kết quả: 0 rows!

-- Tại sao:
-- NOT IN (1, 2, NULL) tương đương:
-- category_id != 1 AND category_id != 2 AND category_id != NULL

-- category_id != NULL → luôn UNKNOWN (không phải TRUE)
-- AND với UNKNOWN → kết quả cuối = UNKNOWN → không match

-- ĐÚNG:
WHERE category_id NOT IN (1, 2);

-- Hoặc:
WHERE category_id NOT IN (
    SELECT category_id 
    FROM categories 
    WHERE category_id IS NOT NULL
);

-- Hoặc dùng NOT EXISTS (an toàn hơn):
WHERE NOT EXISTS (
    SELECT 1 
    FROM (VALUES (1), (2)) AS excluded(id)
    WHERE products.category_id = excluded.id
);
```

**Lesson:** 
- NULL phá hỏng NOT IN
- Dùng NOT EXISTS thay vì NOT IN nếu có nguy cơ NULL
- Hoặc filter NULL trước
</details>

---

### **Exercise 6: Filter Early - JOIN optimization**

```sql
-- Scenario: Lấy danh sách users có orders "delivered" trong 2024

-- Version 1: Filter sau JOIN (BAD)
EXPLAIN ANALYZE
SELECT DISTINCT u.user_id, u.username
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.status = 'delivered'
  AND o.order_date >= '2024-01-01'
  AND o.order_date < '2025-01-01';

-- Version 2: Filter trước JOIN (GOOD)
EXPLAIN ANALYZE
SELECT u.user_id, u.username
FROM users u
WHERE EXISTS (
    SELECT 1 
    FROM orders o
    WHERE o.user_id = u.user_id
      AND o.status = 'delivered'
      AND o.order_date >= '2024-01-01'
      AND o.order_date < '2025-01-01'
);

-- Version 3: CTE filter trước (GOOD)
EXPLAIN ANALYZE
WITH delivered_orders AS (
    SELECT DISTINCT user_id
    FROM orders
    WHERE status = 'delivered'
      AND order_date >= '2024-01-01'
      AND order_date < '2025-01-01'
)
SELECT u.user_id, u.username
FROM users u
JOIN delivered_orders o ON u.user_id = o.user_id;

-- Q: So sánh performance và explain plan
```

<details>
<summary>Đáp án</summary>

**Version 1:**
- JOIN 10,000 users × 50,000 orders = nhiều rows
- Filter sau JOIN
- DISTINCT để dedupe
- Execution time: ~50-200ms

**Version 2:**
- EXISTS: Semi-join, dừng ngay khi tìm thấy match
- Filter sớm trong subquery
- Không cần DISTINCT
- Execution time: ~10-50ms

**Version 3:**
- CTE filter trước: ~5,000 orders → ~2,000 users
- JOIN nhẹ: 10,000 users × 2,000 unique users
- Execution time: ~20-100ms

**Winner: Version 2 (EXISTS)**
- Fastest
- Cleanest plan
- Auto dedupe

**Lesson:** 
- Filter sớm nhất có thể
- EXISTS tốt cho membership check
- Tránh JOIN large tables rồi mới filter
</details>

---

### **Exercise 7: Composite WHERE - Index usage**

```sql
-- Index: CREATE INDEX idx_orders_composite ON orders(status, order_date, user_id);

-- Test 1: Full prefix (BEST)
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE status = 'delivered'
  AND order_date >= '2024-01-01'
  AND user_id = 123;

-- Test 2: Partial prefix (GOOD)
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE status = 'delivered'
  AND order_date >= '2024-01-01';

-- Test 3: Skip first column (BAD - không dùng index)
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE order_date >= '2024-01-01'
  AND user_id = 123;

-- Test 4: Non-contiguous (PARTIAL - chỉ dùng 1 cột)
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE status = 'delivered'
  AND user_id = 123;  -- Skip order_date

-- Q: Explain tại sao Test 3, 4 không optimal?
```

<details>
<summary>Đáp án</summary>

**Leftmost Prefix Rule:**
- Index (status, order_date, user_id) hoạt động như 3 indexes:
  1. (status)
  2. (status, order_date)
  3. (status, order_date, user_id)

**Test 1:** Dùng cả 3 cột → Index Scan (BEST)

**Test 2:** Dùng 2 cột đầu → Index Scan (GOOD)

**Test 3:** Skip cột đầu → **Seq Scan** (không dùng được index)
- Vì không có filter cho `status`
- Index không giúp được gì

**Test 4:** Skip cột giữa → Index Scan trên `status` only
- Dùng được index cho `status`
- `user_id` filter sau (không dùng index)
- Kém hiệu quả hơn

**Lesson:**
- Composite index cần filter từ trái qua phải (leftmost)
- Thiết kế index theo query patterns thực tế
- Đặt cột selective nhất lên đầu
</details>

---

### **Exercise 8: Real-world scenario - API Filter**

**Scenario:** API endpoint filter products

**Requirements:**
```
GET /api/products?category=1&min_price=100&max_price=500&in_stock=true
```

**Viết query tối ưu:**

<details>
<summary>Đáp án</summary>

```sql
-- Bad: Không sử dụng index hiệu quả
SELECT * FROM products
WHERE category_id = 1
  AND price >= 100 
  AND price <= 500
  AND stock > 0;

-- Good: Đúng thứ tự, dùng index
-- Index: CREATE INDEX idx_products_filter ON products(category_id, price, stock);

SELECT 
    product_id,
    product_name,
    price,
    stock
FROM products
WHERE category_id = 1         -- Leftmost: selective
  AND price BETWEEN 100 AND 500  -- Range
  AND stock > 0               -- Filter cuối
ORDER BY price ASC
LIMIT 20;

-- Best: Thêm covering index (nếu query này chạy nhiều)
-- CREATE INDEX idx_products_cover ON products(category_id, price, stock) 
-- INCLUDE (product_id, product_name);

-- Optimization checklist:
-- ✅ WHERE theo leftmost prefix
-- ✅ SELECT only needed columns
-- ✅ LIMIT để giảm rows
-- ✅ Index covers query
```

**Dynamic filters (optional parameters):**
```sql
-- Khi category_id optional
WHERE (category_id = $1 OR $1 IS NULL)
  AND price BETWEEN $2 AND $3
  AND (stock > 0 OR $4 = false);

-- Nhưng cẩn thận: OR $1 IS NULL có thể làm mất index
-- Better: Build query dynamically trong app code
```
</details>

---

## 4. BEST PRACTICES

### ✅ **Rule 1: Filter sớm nhất có thể**
```sql
-- Bad: JOIN trước, filter sau
FROM orders o
JOIN users u ON o.user_id = u.user_id
WHERE o.status = 'delivered';

-- Good: Filter trước JOIN
FROM (SELECT * FROM orders WHERE status = 'delivered') o
JOIN users u ON o.user_id = u.user_id;

-- Better: EXISTS
WHERE EXISTS (SELECT 1 FROM orders o WHERE ...)
```

### ✅ **Rule 2: Giữ indexed column ở left-hand side**
```sql
-- Bad
WHERE DATE(created_at) = '2024-01-15';
WHERE UPPER(username) = 'JOHN';

-- Good
WHERE created_at >= '2024-01-15' AND created_at < '2024-01-16';
WHERE username = 'john';
```

### ✅ **Rule 3: Dùng IN thay vì multiple OR**
```sql
-- Bad
WHERE status = 'pending' OR status = 'processing' OR status = 'shipped';

-- Good
WHERE status IN ('pending', 'processing', 'shipped');
```

### ✅ **Rule 4: Luôn dùng () với AND/OR**
```sql
-- Bad: Khó hiểu
WHERE a = 1 OR b = 2 AND c = 3;

-- Good: Rõ ràng
WHERE (a = 1 OR b = 2) AND c = 3;
```

### ✅ **Rule 5: Cẩn thận với NULL**
```sql
-- Bad
WHERE column = NULL;
WHERE column NOT IN (1, 2, NULL);

-- Good
WHERE column IS NULL;
WHERE column NOT IN (SELECT id FROM table WHERE id IS NOT NULL);
```

### ✅ **Rule 6: Tránh LIKE leading wildcard nếu có thể**
```sql
-- Bad
WHERE name LIKE '%John%';  -- Full scan

-- Good (nếu search "starts with")
WHERE name LIKE 'John%';   -- Index scan

-- Good (nếu thực sự cần full-text)
-- Dùng trigram index hoặc full-text search
```

---

## 5. ANTI-PATTERNS ⚠️

### ❌ **Anti-pattern 1: Function on indexed column**
```sql
-- Bad
WHERE YEAR(order_date) = 2024;
WHERE UPPER(email) = 'JOHN@EXAMPLE.COM';

-- Good
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01';
WHERE email = 'john@example.com';
```

### ❌ **Anti-pattern 2: OR across different columns**
```sql
-- Bad: Không dùng được index hiệu quả
WHERE user_id = 123 OR order_date > '2024-01-01';

-- Good: Tách query hoặc redesign
```

### ❌ **Anti-pattern 3: NOT IN with potential NULL**
```sql
-- Bad
WHERE product_id NOT IN (SELECT category_id FROM categories);

-- Good
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE id = product_id);
```

### ❌ **Anti-pattern 4: Không dùng BETWEEN đúng cách**
```sql
-- Bad: Thiếu records cuối ngày
WHERE date BETWEEN '2024-01-01' AND '2024-01-31';

-- Good
WHERE date >= '2024-01-01' AND date < '2024-02-01';
```

---

## 6. CHECKLIST ĐẠT TASK 04

✅ **Hiểu WHERE optimization:**
- [ ] Biết "filter early" principle
- [ ] Hiểu AND/OR precedence
- [ ] Biết khi nào WHERE dùng được index

✅ **Operators:**
- [ ] Dùng đúng IN, BETWEEN, IS NULL
- [ ] Tránh LIKE leading wildcard
- [ ] Hiểu NULL trong NOT IN

✅ **Index-friendly WHERE:**
- [ ] Không dùng function trên indexed column
- [ ] Rewrite query để dùng index
- [ ] Hiểu leftmost prefix rule

✅ **Performance:**
- [ ] So sánh được Seq Scan vs Index Scan
- [ ] Debug được slow query do WHERE sai
- [ ] Viết WHERE tối ưu cho production

---

## 7. REAL-WORLD CHECKLIST

Khi viết WHERE clause, tự hỏi:

1. **Có filter sớm không?**
   - Filter trước JOIN?
   - Filter trước GROUP BY?

2. **Có dùng được index không?**
   - Column có index?
   - Có function trên column?
   - Có match leftmost prefix?

3. **Có xử lý NULL đúng không?**
   - Dùng IS NULL thay vì = NULL?
   - NOT IN có NULL không?

4. **Performance có OK không?**
   - EXPLAIN ANALYZE để check
   - Index Scan hay Seq Scan?
   - Execution time < SLA?

---

## 8. NEXT STEPS

Bạn đã hoàn thành Task 04 khi:
- ✅ Viết WHERE tối ưu, dùng được index
- ✅ Tránh function trên indexed column
- ✅ Hiểu AND/OR/NOT và NULL semantics
- ✅ Debug slow query do WHERE sai

**→ Tiếp theo: TASK 05 — ORDER BY & Pagination theo chuẩn production**

Pagination sai = performance disaster khi data lớn!
