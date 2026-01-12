# TASK 02 — Đọc Schema như Đọc Business

> **Mục tiêu**: Nhìn bảng/cột/khóa là hiểu luồng nghiệp vụ; tránh join sai dẫn tới thống kê sai.

---

## 1. THEORY — Nền tảng đọc schema

### 1.1. PK (Primary Key) - Định danh duy nhất
**Khái niệm**
- Mỗi bảng nên có PK để định danh duy nhất mỗi record
- PK không được NULL, không được trùng
- PK tự động tạo index (unique + clustered trong một số DB)

**Business meaning**
- `users.user_id` → mỗi user là 1 con người/tài khoản duy nhất
- `orders.order_id` → mỗi đơn hàng là 1 giao dịch riêng biệt
- `products.product_id` → mỗi sản phẩm là 1 SKU

**Câu hỏi tự kiểm tra**
- PK này có ý nghĩa nghiệp vụ gì?
- Có trường hợp nào 2 record có PK giống nhau không? → KHÔNG

---

### 1.2. FK (Foreign Key) - Mối quan hệ giữa các bảng
**Khái niệm**
- FK trong bảng A trỏ đến PK của bảng B
- FK giữ tính toàn vẹn dữ liệu (referential integrity)
- FK giúp hiểu luồng nghiệp vụ: "ai thuộc về ai"

**Business meaning**
```
orders.user_id → users.user_id
  → Đơn hàng thuộc về user nào?
  
order_items.order_id → orders.order_id
  → Chi tiết đơn hàng thuộc đơn nào?
  
order_items.product_id → products.product_id
  → Chi tiết đơn hàng mua sản phẩm gì?
```

**CASCADE behavior (quan trọng)**
- `ON DELETE CASCADE`: xóa parent → xóa luôn child (cẩn thận!)
- `ON DELETE RESTRICT`: không cho xóa parent nếu còn child
- `ON UPDATE CASCADE`: update PK parent → update luôn FK child

---

### 1.3. Cardinality - Số lượng quan hệ

#### **1:1 (One-to-One)**
```
users ←→ user_profiles
  user_id PK      user_id PK,FK
```
- Mỗi user có 1 profile, mỗi profile thuộc 1 user
- **Khi nào dùng**: tách bảng để tối ưu (bảng chính nhỏ, bảng profile có nhiều cột ít dùng)

#### **1:N (One-to-Many)** ← Phổ biến nhất
```
users ←→ orders
  user_id PK      order_id PK
                  user_id FK
```
- 1 user có nhiều orders
- 1 order chỉ thuộc 1 user
- **Business**: Khách hàng mua nhiều đơn hàng

#### **N:N (Many-to-Many)**
```
products ←→ order_items ←→ orders
  product_id      product_id FK     order_id
                  order_id FK
```
- 1 order có nhiều products
- 1 product có thể trong nhiều orders
- **Giải pháp**: Bảng trung gian (junction/bridge table) `order_items`

---

### 1.4. Fact Table vs Master Table (Dimension Table)

#### **Master/Dimension Table** (Bảng tra cứu)
- Lưu thông tin "gốc", ít thay đổi
- Thường có PK
- Ví dụ: `users`, `products`, `categories`, `countries`

**Đặc điểm**
```sql
-- users (Master)
user_id | username | email         | created_at
--------|----------|---------------|------------
1       | john     | john@mail.com | 2024-01-01
2       | alice    | alice@...     | 2024-01-02
```
- Ít row (hàng nghìn đến vài triệu)
- Nhiều được JOIN
- Ít INSERT/UPDATE

#### **Fact Table** (Bảng sự kiện)
- Lưu giao dịch, sự kiện, hành động
- Thường có nhiều FK trỏ đến Master
- Ví dụ: `orders`, `order_items`, `payments`, `logs`

**Đặc điểm**
```sql
-- orders (Fact)
order_id | user_id | order_date | total_amount | status
---------|---------|------------|--------------|--------
1001     | 1       | 2024-05-01 | 150.00       | paid
1002     | 2       | 2024-05-01 | 200.00       | pending
1003     | 1       | 2024-05-02 | 99.00        | paid
```
- Nhiều row (hàng triệu đến tỷ)
- Ít được JOIN như parent
- Nhiều INSERT, ít UPDATE

---

### 1.5. NULL Semantics - "Bẫy" lớn nhất của SQL

#### **NULL ≠ 0 ≠ '' (empty string)**
```sql
-- SAI
WHERE discount = NULL     -- sai, luôn false
WHERE discount != NULL    -- sai, luôn false

-- ĐÚNG
WHERE discount IS NULL
WHERE discount IS NOT NULL
```

#### **NULL trong tính toán**
```sql
SELECT 100 + NULL;        -- NULL
SELECT 100 * NULL;        -- NULL
SELECT 'Hello' || NULL;   -- NULL
```
→ **1 NULL làm hỏng cả phép tính**

#### **NULL trong COUNT**
```sql
SELECT COUNT(*) FROM orders;           -- đếm tất cả rows
SELECT COUNT(shipped_date) FROM orders; -- đếm rows có shipped_date NOT NULL
```

#### **NULL trong JOIN**
```sql
-- LEFT JOIN giữ NULL
SELECT u.username, o.order_id
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id;
-- User chưa đặt hàng → o.order_id = NULL
```

#### **NULL trong GROUP BY**
```sql
SELECT category, COUNT(*)
FROM products
GROUP BY category;
-- NULL category được group thành 1 nhóm riêng
```

---

## 2. PRACTICE — Thực hành với PostgreSQL

### Setup Database

```sql
-- Tạo database mẫu
CREATE DATABASE ecommerce_practice;
\c ecommerce_practice;

-- 1. Master: Users
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Master: Categories
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    parent_category_id INTEGER,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- 3. Master: Products
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INTEGER,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 4. Fact: Orders
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    shipped_date TIMESTAMP NULL,  -- Chú ý: NULL
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 5. Fact: Order Items (N:N junction)
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) NULL,  -- Chú ý: NULL
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 6. 1:1 User Profiles
CREATE TABLE user_profiles (
    user_id INTEGER PRIMARY KEY,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Insert sample data
INSERT INTO users (username, email) VALUES
('john_doe', 'john@example.com'),
('alice_wonder', 'alice@example.com'),
('bob_builder', 'bob@example.com'),
('charlie_brown', 'charlie@example.com');

INSERT INTO categories (category_name, parent_category_id) VALUES
('Electronics', NULL),
('Phones', 1),
('Laptops', 1),
('Clothing', NULL),
('Men', 4),
('Women', 4);

INSERT INTO products (product_name, category_id, price, stock) VALUES
('iPhone 15', 2, 999.99, 50),
('Samsung Galaxy S24', 2, 899.99, 30),
('MacBook Pro', 3, 2499.99, 20),
('Dell XPS 13', 3, 1299.99, 15),
('T-Shirt', 5, 29.99, 100),
('Jeans', 5, 79.99, 50),
('Dress', 6, 99.99, 40),
('Headphones', 1, 199.99, NULL);  -- NULL stock

INSERT INTO orders (user_id, order_date, status, shipped_date) VALUES
(1, '2024-01-15', 'delivered', '2024-01-16'),
(1, '2024-02-20', 'delivered', '2024-02-21'),
(2, '2024-03-10', 'pending', NULL),  -- chưa ship
(3, '2024-03-15', 'shipped', '2024-03-16'),
(4, '2024-03-20', 'cancelled', NULL);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount) VALUES
(1, 1, 1, 999.99, NULL),
(1, 8, 1, 199.99, 20.00),  -- có discount
(2, 3, 1, 2499.99, NULL),
(3, 5, 2, 29.99, NULL),
(3, 6, 1, 79.99, 10.00),   -- có discount
(4, 2, 1, 899.99, NULL);

INSERT INTO user_profiles (user_id, full_name, phone) VALUES
(1, 'John Doe', '555-0101'),
(2, 'Alice Wonder', '555-0102');
-- Chú ý: user 3, 4 không có profile (1:1 optional)
```

---

## 3. BÀI TẬP THỰC HÀNH

### **Exercise 1: Phân biệt Master vs Fact**

**Câu hỏi:**
1. Những bảng nào là Master? Tại sao?
2. Những bảng nào là Fact? Tại sao?
3. Bảng nào có xu hướng tăng row nhanh nhất?

<details>
<summary>Đáp án</summary>

**Master:** users, categories, products, user_profiles
- Lưu thông tin gốc, ít thay đổi
- Được JOIN nhiều

**Fact:** orders, order_items
- Lưu giao dịch, sự kiện
- Row tăng liên tục theo thời gian

**Tăng nhanh nhất:** order_items (mỗi đơn hàng có nhiều items)
</details>

---

### **Exercise 2: Xác định Cardinality**

**Câu hỏi:** Xác định quan hệ giữa các bảng:
1. users ↔ orders
2. orders ↔ order_items
3. products ↔ order_items
4. users ↔ user_profiles
5. categories ↔ categories (self-reference)

<details>
<summary>Đáp án</summary>

1. **users ↔ orders**: 1:N (1 user nhiều orders)
2. **orders ↔ order_items**: 1:N (1 order nhiều items)
3. **products ↔ order_items**: N:N qua order_items (1 product trong nhiều orders, 1 order nhiều products)
4. **users ↔ user_profiles**: 1:1 (optional)
5. **categories ↔ categories**: 1:N (parent-child hierarchy)
</details>

---

### **Exercise 3: NULL Hunting - Tìm và hiểu NULL**

```sql
-- Q1: Có bao nhiêu products chưa có category?
SELECT COUNT(*) FROM products WHERE category_id IS NULL;

-- Q2: Có bao nhiêu products có stock = NULL?
SELECT COUNT(*) FROM products WHERE stock IS NULL;

-- Q3: Có bao nhiêu orders chưa shipped (shipped_date = NULL)?
SELECT COUNT(*) FROM orders WHERE shipped_date IS NULL;

-- Q4: Có bao nhiêu order_items không có discount?
SELECT COUNT(*) FROM order_items WHERE discount IS NULL;

-- Q5: Tính tổng discount (chú ý NULL!)
-- Cách SAI:
SELECT SUM(discount) FROM order_items;  -- NULL bị bỏ qua, kết quả = 30

-- Cách ĐÚNG (convert NULL → 0):
SELECT SUM(COALESCE(discount, 0)) FROM order_items;
```

**Bài tập:**
1. Tìm tất cả users KHÔNG có profile
2. Tìm tất cả products có stock NULL hoặc = 0
3. Tính tổng discount, count bao nhiêu items có discount

<details>
<summary>Đáp án</summary>

```sql
-- 1. Users không có profile
SELECT u.user_id, u.username
FROM users u
LEFT JOIN user_profiles up ON u.user_id = up.user_id
WHERE up.user_id IS NULL;

-- 2. Products có stock NULL hoặc 0
SELECT product_id, product_name, stock
FROM products
WHERE stock IS NULL OR stock = 0;

-- 3. Tổng discount và count
SELECT 
    SUM(COALESCE(discount, 0)) as total_discount,
    COUNT(discount) as items_with_discount,  -- chỉ đếm NOT NULL
    COUNT(*) as total_items
FROM order_items;
```
</details>

---

### **Exercise 4: Đọc schema để trả lời business**

**Không viết query, chỉ dựa vào schema để trả lời:**

1. Làm sao biết 1 user đã đặt bao nhiêu đơn hàng?
2. Làm sao biết 1 sản phẩm được bán bao nhiêu lần?
3. Làm sao biết tổng doanh thu của 1 đơn hàng?
4. Làm sao tìm tất cả đơn hàng của user "john_doe"?
5. Làm sao tìm category cha của "Phones"?

<details>
<summary>Đáp án</summary>

1. **COUNT orders theo user_id:** `orders.user_id → users.user_id`
2. **COUNT order_items theo product_id:** `order_items.product_id → products.product_id`
3. **SUM từ order_items:** `order_items.order_id → orders.order_id`, sum (quantity * unit_price - discount)
4. **JOIN users → orders:** WHERE users.username = 'john_doe'
5. **Self-join categories:** `categories.parent_category_id → categories.category_id` WHERE category_name = 'Phones'
</details>

---

### **Exercise 5: Phát hiện lỗi thiết kế**

**Câu hỏi:** Schema hiện tại có vấn đề gì?

```sql
-- Vấn đề 1: orders.total_amount có thể sai lệch
-- total_amount được lưu nhưng có thể không = tổng order_items
-- → Denormalization risk

-- Vấn đề 2: products.stock không giảm khi order
-- → Cần trigger hoặc app logic

-- Vấn đề 3: order_items.unit_price
-- Tại sao không dùng products.price?
-- → Đúng! Giá sản phẩm có thể thay đổi, cần lưu giá tại thời điểm mua
```

**Bài tập:** Viết query kiểm tra orders có total_amount đúng không

<details>
<summary>Đáp án</summary>

```sql
SELECT 
    o.order_id,
    o.total_amount as stored_total,
    SUM(oi.quantity * oi.unit_price - COALESCE(oi.discount, 0)) as calculated_total,
    o.total_amount - SUM(oi.quantity * oi.unit_price - COALESCE(oi.discount, 0)) as difference
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount IS NOT NULL 
   AND ABS(o.total_amount - SUM(oi.quantity * oi.unit_price - COALESCE(oi.discount, 0))) > 0.01;
```
</details>

---

### **Exercise 6: CASCADE behavior**

```sql
-- Test ON DELETE CASCADE
-- Xóa order sẽ xóa luôn order_items?

-- Kiểm tra trước khi xóa
SELECT * FROM orders WHERE order_id = 4;
SELECT * FROM order_items WHERE order_id = 4;

-- Xóa order
DELETE FROM orders WHERE order_id = 4;

-- Kiểm tra sau khi xóa
SELECT * FROM order_items WHERE order_id = 4;  -- Nên = 0 rows

-- Test ON DELETE RESTRICT
-- Thử xóa user có orders → sẽ bị lỗi
DELETE FROM users WHERE user_id = 1;  
-- ERROR: violates foreign key constraint
```

**Câu hỏi:**
1. Tại sao orders → order_items dùng CASCADE?
2. Tại sao users → orders KHÔNG dùng CASCADE?

<details>
<summary>Đáp án</summary>

1. **CASCADE hợp lý:** Xóa đơn hàng → xóa luôn chi tiết đơn hàng (business logic đúng)
2. **KHÔNG CASCADE:** Xóa user KHÔNG nên xóa đơn hàng (cần giữ lịch sử giao dịch). Nên dùng soft delete cho users.
</details>

---

## 4. CHECKLIST ĐẠT TASK 02

✅ **Hiểu PK/FK:**
- [ ] Biết PK là gì, tại sao cần PK
- [ ] Biết FK là gì, đọc FK là hiểu luồng business
- [ ] Hiểu CASCADE behavior (DELETE, UPDATE)

✅ **Phân biệt Cardinality:**
- [ ] Nhận diện 1:1, 1:N, N:N chỉ bằng nhìn schema
- [ ] Biết N:N cần bảng trung gian

✅ **Master vs Fact:**
- [ ] Phân biệt được bảng nào là Master, bảng nào là Fact
- [ ] Hiểu Fact table có xu hướng lớn nhanh

✅ **NULL Semantics:**
- [ ] NULL ≠ 0 ≠ ''
- [ ] Dùng IS NULL, không dùng = NULL
- [ ] Hiểu NULL trong COUNT, SUM, JOIN

✅ **Đọc schema trả lời business:**
- [ ] Nhìn schema biết query nào cần JOIN nào
- [ ] Nhận diện được lỗi thiết kế tiềm năng

---

## 5. NEXT STEP

Sau khi hoàn thành Task 02, bạn đã:
- Hiểu cấu trúc dữ liệu như hiểu nghiệp vụ
- Sẵn sàng viết query JOIN đúng (Task 07, 08)
- Tránh được lỗi sai logic do hiểu sai schema

**→ Tiếp theo: TASK 03 — SELECT tối thiểu, đúng thứ cần**
