# TASK 01 — Hiểu "Doanh nghiệp dùng SQL để làm gì"

> **Mục tiêu**: Nắm bối cảnh thực tế để biết SQL không chỉ để "query cho vui", mà phục vụ **giao dịch, báo cáo, phân quyền, batch** với yêu cầu về **tốc độ, chi phí, độ chính xác**.

---

## 🎯 Tại sao phải học phần này?

Nhiều người học SQL chỉ biết `SELECT * FROM users WHERE id = 1` nhưng không hiểu:
- ❓ Tại sao query này chạy nhanh mà query kia chậm?
- ❓ Tại sao có cái cần trả về trong **100ms** (API) mà có cái được chạy **2 giờ** (batch)?
- ❓ Tại sao bảng này có 10 triệu dòng mà vẫn nhanh, bảng kia 100k dòng lại chậm?

**Câu trả lời**: Vì **mục đích sử dụng khác nhau** → thiết kế và tối ưu khác nhau.

---

## 📊 Phân loại hệ thống: OLTP vs OLAP

### 1. OLTP (Online Transaction Processing) - Hệ thống giao dịch

**Đặc điểm**:
- Phục vụ **giao dịch nghiệp vụ** hàng ngày (mua hàng, đăng ký, cập nhật thông tin)
- **Query đơn giản**, đọc/ghi **ít row**, nhưng **tần suất cao**
- Yêu cầu **độ trễ thấp** (< 100ms) và **consistency cao** (ACID)
- Ưu tiên **Write performance** và **Concurrency**

**Ví dụ thực tế**:
```sql
-- API: Lấy thông tin user khi login
SELECT user_id, username, email, status 
FROM users 
WHERE email = 'john@example.com' AND status = 'active';
-- ⏱️ Phải trả về trong < 50ms

-- API: Tạo đơn hàng mới
INSERT INTO orders (user_id, total_amount, status, created_at)
VALUES (12345, 150000, 'pending', NOW());
-- ⏱️ Phải hoàn thành trong < 100ms

-- API: Cập nhật số lượng tồn kho
UPDATE products 
SET stock = stock - 1 
WHERE product_id = 789 AND stock > 0;
-- ⏱️ Phải nhanh + đảm bảo không bán quá số lượng (ACID)
```

**Đặc điểm DB**:
- Index nhiều để đọc/ghi nhanh
- Normalize cao để tránh duplicate
- Transaction & lock để đảm bảo consistency
- Row-based storage (PostgreSQL, MySQL, Oracle)

---

### 2. OLAP (Online Analytical Processing) - Hệ thống phân tích

**Đặc điểm**:
- Phục vụ **báo cáo, dashboard, BI, data mining**
- **Query phức tạp**, scan **nhiều row**, nhưng **tần suất thấp**
- Được phép **chạy chậm** (vài giây đến vài phút)
- Ưu tiên **Read performance** với data lớn

**Ví dụ thực tế**:
```sql
-- Dashboard: Doanh thu theo tháng trong năm 2025
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE created_at >= '2025-01-01' 
  AND created_at < '2026-01-01'
  AND status IN ('completed', 'shipped')
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month;
-- ⏱️ Được phép chạy 2-5 giây, scan hàng triệu rows

-- Report: Top 10 sản phẩm bán chạy
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.created_at >= NOW() - INTERVAL '30 days'
GROUP BY p.product_id, p.product_name
ORDER BY total_sold DESC
LIMIT 10;
-- ⏱️ Được phép chạy 5-10 giây
```

**Đặc điểm DB**:
- Denormalize để giảm join
- Aggregate trước (pre-aggregation, materialized views)
- Partition theo thời gian/region
- Column-based storage (Redshift, BigQuery, ClickHouse)

---

## 📋 So sánh trực quan

| Tiêu chí | OLTP | OLAP |
|----------|------|------|
| **Mục đích** | Giao dịch nghiệp vụ | Phân tích, báo cáo |
| **Users** | Nhiều (hàng nghìn/triệu) | Ít (vài chục analyst) |
| **Query type** | Simple (SELECT/INSERT/UPDATE) | Complex (JOIN/GROUP/Window) |
| **Data access** | Ít rows, tần suất cao | Nhiều rows, tần suất thấp |
| **Latency** | < 100ms | Vài giây → vài phút |
| **Data size per query** | KB - MB | MB - GB |
| **Transactions** | Cần ACID, nhiều lock | Ít transaction, read-only |
| **Schema** | Normalize (3NF) | Denormalize (Star/Snowflake) |
| **Storage** | Row-based | Column-based |
| **Index strategy** | Nhiều index cho write/read | Ít index, partition nhiều |
| **Examples** | PostgreSQL, MySQL, Oracle | Redshift, BigQuery, Snowflake |

---

## ⏱️ SLA và Latency - Yêu cầu tốc độ

### SLA (Service Level Agreement) - Cam kết mức độ dịch vụ

Doanh nghiệp cam kết với khách hàng về **độ nhanh** và **độ tin cậy**:

| Use case | SLA Latency | Uptime | Lý do |
|----------|-------------|--------|-------|
| **API Login** | < 50ms | 99.99% | Ảnh hưởng trải nghiệm user |
| **API Checkout** | < 100ms | 99.95% | Mất khách nếu chậm |
| **Dashboard load** | < 2s | 99.5% | Không critical như API |
| **Nightly report** | < 2 hours | 99% | Chạy ban đêm, có buffer |
| **Monthly batch** | < 8 hours | 95% | Chạy cuối tháng, ít critical |

**Ví dụ thực tế**:
```sql
-- ❌ KHÔNG được làm thế này trong API endpoint
-- Scan toàn bộ bảng orders (10M rows) → 5 giây
SELECT * FROM orders WHERE status = 'pending';

-- ✅ Đúng: Filter + Index + Limit
SELECT order_id, user_id, total_amount, created_at
FROM orders 
WHERE status = 'pending' 
  AND created_at >= NOW() - INTERVAL '7 days'
ORDER BY created_at DESC
LIMIT 100;
-- ⏱️ < 50ms với index (status, created_at)
```

### Hậu quả khi vi phạm SLA:

1. **API chậm** → User rời bỏ app (mất tiền)
2. **Query chậm** → Block connection pool → Toàn bộ app bị chậm
3. **Vi phạm SLA** → Phạt tiền theo hợp đồng (AWS/GCP)

---

## 📦 Data Lifecycle - Vòng đời dữ liệu

Dữ liệu không phải lúc nào cũng "nóng" như nhau:

### 1. **Hot Data** (Dữ liệu nóng)
- **Đặc điểm**: Truy cập **thường xuyên**, cần **nhanh**
- **Ví dụ**: Orders trong 7 ngày gần nhất, active users, products có sẵn
- **Storage**: SSD, nhiều index, cache
- **Cost**: Đắt nhất

```sql
-- Hot data: Orders trong 7 ngày
SELECT * FROM orders 
WHERE created_at >= NOW() - INTERVAL '7 days';
```

### 2. **Warm Data** (Dữ liệu ấm)
- **Đặc điểm**: Truy cập **thỉnh thoảng**, chậm được
- **Ví dụ**: Orders 1-12 tháng trước, old user profiles
- **Storage**: Standard disk, ít index hơn
- **Cost**: Trung bình

```sql
-- Warm data: Orders trong 6 tháng
SELECT * FROM orders_archive 
WHERE created_at >= NOW() - INTERVAL '6 months';
```

### 3. **Cold Data** (Dữ liệu lạnh)
- **Đặc điểm**: **Hiếm khi** truy cập, chỉ lưu cho pháp lý/audit
- **Ví dụ**: Orders 2+ năm trước, deleted users, old logs
- **Storage**: Archive (S3 Glacier, tape), không index
- **Cost**: Rất rẻ (1/10 so với hot)

```sql
-- Cold data: Lưu ở warehouse hoặc S3
-- Truy vấn qua data lake/ETL tool
```

### Chiến lược Archiving

```sql
-- Mỗi tháng, move data > 1 năm sang bảng archive
INSERT INTO orders_archive 
SELECT * FROM orders 
WHERE created_at < NOW() - INTERVAL '1 year';

DELETE FROM orders 
WHERE created_at < NOW() - INTERVAL '1 year';

-- Hoặc dùng Partition (TASK 17 sẽ học)
```

**Lợi ích**:
- Giảm size bảng chính → Query nhanh hơn
- Giảm chi phí storage
- Backup nhanh hơn

---

## 💰 Chi phí - Tại sao phải tối ưu?

### 1. Chi phí tính toán (CPU/Memory)

**Ví dụ AWS RDS PostgreSQL**:
- `db.t3.medium` (2 vCPU, 4GB RAM): **$61/tháng**
- `db.m5.2xlarge` (8 vCPU, 32GB RAM): **$490/tháng**

**Scenario**:
```sql
-- Query tệ: Full scan 50M rows → Dùng 100% CPU → 10 giây
SELECT * FROM orders WHERE YEAR(created_at) = 2025;

-- Cần upgrade lên instance lớn hơn → +$400/tháng

-- ✅ Query tốt: Index scan → Dùng 5% CPU → 50ms
SELECT * FROM orders 
WHERE created_at >= '2025-01-01' 
  AND created_at < '2026-01-01';

-- Không cần upgrade → Tiết kiệm $400/tháng = $4,800/năm
```

### 2. Chi phí Storage

| Storage Type | Cost (AWS) | Use case |
|--------------|-----------|----------|
| SSD (gp3) | **$0.08/GB/tháng** | Hot data |
| HDD (sc1) | **$0.015/GB/tháng** | Warm data |
| S3 Standard | **$0.023/GB/tháng** | Archive |
| S3 Glacier | **$0.004/GB/tháng** | Cold data |

**Ví dụ**: 1TB data
- Tất cả lưu SSD: **$80/tháng**
- Split: 100GB SSD + 900GB S3: **$28.7/tháng** (tiết kiệm 64%)

### 3. Chi phí gián tiếp

| Vấn đề | Hậu quả | Chi phí |
|--------|---------|---------|
| Query chậm | API timeout → User rời bỏ | **Mất khách hàng** |
| Connection leak | DB bị full connection | **Downtime** |
| Lock nhiều | Deadlock → Transaction fail | **Dữ liệu sai** |
| No monitoring | Không phát hiện issue sớm | **Fire-fighting** |

---

## 🎓 Bài tập thực hành

### Bài 1: Phân loại use case
Xác định mỗi scenario sau là **OLTP** hay **OLAP**:

1. User click "Xem giỏ hàng" → Lấy 5 sản phẩm trong giỏ
2. CEO xem "Doanh thu toàn công ty năm 2025"
3. User đặt hàng → Tạo order mới + trừ stock
4. Analyst export "Danh sách khách hàng VIP" (10k records)
5. Mobile app load "10 bài viết mới nhất"
6. Batch job "Tính commission cho 5000 nhân viên"

<details>
<summary>Đáp án</summary>

1. **OLTP** - API, ít rows, nhanh
2. **OLAP** - Aggregate toàn bộ data, chậm OK
3. **OLTP** - Transaction, cần ACID
4. **OLAP** - Bulk read, ít tần suất
5. **OLTP** - API, phải nhanh
6. **Batch** - Có thể chạy lâu, nhưng cần chunking

</details>

---

### Bài 2: Tính chi phí
Bạn có bảng `orders` với 50 triệu rows:
- Data size: 100GB
- Hiện tại lưu toàn bộ trên SSD (gp3): $0.08/GB/tháng

Chiến lược mới:
- Hot data (3 tháng gần): 15GB trên SSD
- Warm data (9 tháng còn lại): 35GB trên HDD: $0.015/GB/tháng  
- Cold data (>1 năm): 50GB trên S3: $0.023/GB/tháng

**Câu hỏi**: Tiết kiệm được bao nhiêu mỗi tháng?

<details>
<summary>Đáp án</summary>

**Hiện tại**:
- 100GB × $0.08 = **$8/tháng**

**Sau khi tối ưu**:
- 15GB SSD: 15 × $0.08 = $1.2
- 35GB HDD: 35 × $0.015 = $0.525
- 50GB S3: 50 × $0.023 = $1.15
- **Tổng: $2.875/tháng**

**Tiết kiệm**: $8 - $2.875 = **$5.125/tháng** = **$61.5/năm**

(Con số thực tế lớn hơn nhiều khi scale lên TB data)

</details>

---

### Bài 3: Đánh giá query

Query này chạy trong API endpoint (cần < 100ms):
```sql
SELECT 
    u.username,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE u.user_id = 12345
GROUP BY u.username;
```

**Câu hỏi**: 
1. Query này có vấn đề gì?
2. Làm sao để tối ưu?

<details>
<summary>Gợi ý</summary>

**Vấn đề**:
1. Không cần GROUP BY nếu chỉ lấy 1 user
2. COUNT(*) nhanh hơn COUNT(column)
3. Nên filter orders theo user trước khi join

**Tối ưu**:
```sql
SELECT 
    u.username,
    COALESCE(o.total_orders, 0) AS total_orders,
    COALESCE(o.total_spent, 0) AS total_spent
FROM users u
LEFT JOIN (
    SELECT 
        user_id,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_spent
    FROM orders
    WHERE user_id = 12345  -- Filter sớm
    GROUP BY user_id
) o ON u.user_id = o.user_id
WHERE u.user_id = 12345;
```

Hoặc đơn giản hơn: Tách thành 2 query riêng biệt ở tầng app.

</details>

---

## ✅ Checklist hoàn thành TASK 01

Bạn pass task này khi:

- [ ] Phân biệt được OLTP vs OLAP
- [ ] Hiểu tại sao API cần < 100ms mà report được chạy lâu
- [ ] Biết khái niệm hot/warm/cold data và lợi ích archiving
- [ ] Hiểu query chậm = tốn tiền (CPU, storage, opportunity cost)
- [ ] Nhìn vào use case đoán được cần tối ưu gì (index? partition? cache?)

---

## 🎯 Câu hỏi tự kiểm tra

1. **Tại sao không nên dùng `SELECT *` trong API endpoint?**
2. **Dashboard chạy 10 giây có sao không? Còn API thì sao?**
3. **Bảng 100 triệu rows có nhất thiết phải chậm không?**
4. **Khi nào nên archive dữ liệu cũ?**
5. **Index có phải càng nhiều càng tốt không?** (Hint: Đợi TASK 12)

---

## 📝 Đáp án chi tiết

### 1. Tại sao không nên dùng `SELECT *` trong API endpoint?

#### ❌ Vấn đề với `SELECT *`:

```sql
-- ❌ BAD: API endpoint
SELECT * FROM users WHERE user_id = 12345;
```

#### **Lý do KHÔNG nên dùng**:

**a) Lãng phí bandwidth (Tốn network)**
```sql
-- Bảng users có 20 cột, mỗi row ~2KB
-- SELECT * → Trả về: id, username, email, password_hash, 
--   created_at, updated_at, bio, avatar_url, phone, address,
--   city, country, zip_code, preferences, settings, ...

-- Client chỉ cần: username, email, avatar_url (200 bytes)
-- → Lãng phí 1,800 bytes = 90% bandwidth!
```

**b) Lộ dữ liệu nhạy cảm**
```sql
-- SELECT * → Trả về cả: password_hash, secret_key, internal_notes
-- → Nếu dev quên filter ở app layer → Lộ password!
```

**c) Breaking changes khi thêm cột**
```sql
-- Hôm nay: users có 10 cột
SELECT * FROM users;  -- App expect 10 cột

-- Ngày mai: DBA thêm cột ssn (số an sinh xã hội)
ALTER TABLE users ADD COLUMN ssn VARCHAR(20);

-- SELECT * bây giờ trả về 11 cột → App crash!
-- Hoặc worse: Lộ SSN ra ngoài
```

**d) Không tối ưu được index**
```sql
-- PostgreSQL phải đọc toàn bộ row từ disk (include all columns)
-- Không thể dùng Index-only scan (covering index)

-- ✅ Nếu chỉ SELECT username, email → Có thể dùng index cover
```

**e) Tốn memory & CPU**
```sql
-- DB phải:
-- 1. Đọc 20 cột từ disk (I/O)
-- 2. Deserialize 20 cột (CPU)
-- 3. Gửi 20 cột qua network (bandwidth)
-- 4. Client deserialize 20 cột (CPU)

-- × 1000 requests/giây = Lãng phí khủng khiếp!
```

#### ✅ Đúng cách:

```sql
-- ✅ GOOD: Chỉ lấy cột cần thiết
SELECT user_id, username, email, avatar_url, created_at
FROM users 
WHERE user_id = 12345;

-- Lợi ích:
-- - Giảm 90% data transfer
-- - Không lộ sensitive data
-- - Explicit về dependency (dễ refactor)
-- - Có thể dùng covering index
```

---

### 2. Dashboard chạy 10 giây có sao không? Còn API thì sao?

#### 📊 Dashboard chạy 10 giây:

**✅ Có thể chấp nhận được**, nếu:

1. **User expect chậm**:
   - Dashboard thường có loading indicator
   - User biết đang tính toán data lớn
   
2. **Không block hệ thống**:
   - Query chạy trên replica/read-only DB
   - Không làm chậm OLTP

3. **Có caching**:
   ```sql
   -- Cache result 5 phút
   -- User refresh → Lấy từ cache, không query lại
   ```

4. **Async loading**:
   ```javascript
   // Load từng phần, không đợi hết 10 giây
   loadChartData();      // 2s
   loadTableData();      // 3s  
   loadMetrics();        // 5s
   // User thấy data hiện dần, không cảm giác "đơ"
   ```

**⚠️ Nhưng nên cải thiện**:

```sql
-- Option 1: Pre-aggregate (Materialized View)
CREATE MATERIALIZED VIEW dashboard_daily_summary AS
SELECT 
    DATE(created_at) AS date,
    COUNT(*) AS orders,
    SUM(total_amount) AS revenue
FROM orders
GROUP BY DATE(created_at);

-- Refresh mỗi đêm
REFRESH MATERIALIZED VIEW dashboard_daily_summary;

-- Query dashboard: < 100ms thay vì 10s
SELECT * FROM dashboard_daily_summary 
WHERE date >= CURRENT_DATE - 30;
```

#### 🚨 API chạy 10 giây:

**❌ KHÔNG BAO GIỜ được chấp nhận!**

**Lý do**:

**a) User experience tệ**
```
API timeout (thường 30s-60s)
→ User thấy "Loading..." 10s 
→ User nghĩ app bị lỗi
→ User tắt app
→ Mất khách hàng
```

**b) Block connection pool**
```sql
-- Connection pool: 100 connections
-- Mỗi request API giữ connection 10s
-- → 10 requests/giây × 10s = 100 connections đầy!
-- → Request thứ 101 phải chờ → Timeout
-- → Toàn bộ app DOWN
```

**c) Vi phạm SLA**
```
SLA cam kết: < 100ms
Thực tế: 10,000ms
→ Phạt tiền theo hợp đồng
→ Mất uy tín
```

**d) Cascade failure**
```
Mobile App → API Gateway (10s timeout)
           → Backend Service (10s)
              → Database (10s query)

→ Timeout lan truyền
→ Retry storm (mobile retry 3 lần)
→ Database overload
→ Toàn bộ hệ thống sập
```

#### 📋 So sánh:

| Tiêu chí | Dashboard (10s) | API (10s) |
|----------|-----------------|-----------|
| **Acceptable?** | ⚠️ Tạm được | ❌ Tuyệt đối không |
| **User expectation** | Chấp nhận chậm | Phải nhanh |
| **Frequency** | 10-100 lần/ngày | 1000+ lần/giây |
| **Retry behavior** | Không retry | Auto retry → worse |
| **Impact** | Chỉ 1 user chờ | Toàn bộ app chậm |
| **SLA** | Không có | < 100ms |
| **Solution** | Cache, pre-agg | Index, optimize, cache |

---

### 3. Bảng 100 triệu rows có nhất thiết phải chậm không?

**❌ KHÔNG! Kích thước ≠ Tốc độ**

Query nhanh hay chậm phụ thuộc vào:

#### ✅ **Trường hợp NHANH** (100M rows vẫn < 50ms):

**1. Có index đúng**
```sql
-- Bảng orders: 100M rows
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);

-- Query: < 50ms
SELECT * FROM orders 
WHERE user_id = 12345 
  AND created_at >= '2025-01-01'
ORDER BY created_at DESC 
LIMIT 10;

-- Explain: Index Scan → Chỉ đọc 10 rows
```

**2. Query ít rows**
```sql
-- Primary key lookup: O(log n) ≈ 27 operations cho 100M rows
SELECT * FROM orders WHERE order_id = 9999999;
-- ⏱️ < 5ms (dù có 100M rows)
```

**3. Partition hiệu quả**
```sql
-- Partition theo tháng
CREATE TABLE orders (
    order_id BIGINT,
    created_at DATE,
    ...
) PARTITION BY RANGE (created_at);

-- Query chỉ scan 1 partition (3M rows) thay vì 100M
SELECT * FROM orders 
WHERE created_at >= '2025-01-01' AND created_at < '2025-02-01';
-- ⏱️ < 100ms
```

**4. Covering index (Index-only scan)**
```sql
CREATE INDEX idx_orders_cover ON orders(user_id, created_at, total_amount);

-- Query không cần đọc table, chỉ đọc index
SELECT user_id, created_at, total_amount 
FROM orders 
WHERE user_id = 12345;
-- ⏱️ < 10ms (siêu nhanh!)
```

#### ❌ **Trường hợp CHẬM** (100k rows cũng chậm):

**1. Không có index**
```sql
-- Full table scan 100M rows
SELECT * FROM orders WHERE status = 'pending';
-- ⏱️ 30-60 giây (dù chỉ trả về 100 rows)
```

**2. Function trong WHERE**
```sql
-- Không dùng được index
SELECT * FROM orders 
WHERE YEAR(created_at) = 2025;
-- ⏱️ Chậm! (scan toàn bộ)

-- ✅ Đúng:
WHERE created_at >= '2025-01-01' AND created_at < '2026-01-01';
```

**3. Implicit type conversion**
```sql
-- order_id là BIGINT
SELECT * FROM orders WHERE order_id = '12345';  -- String
-- → PostgreSQL convert mỗi row → Không dùng index
```

**4. Join không đúng cách**
```sql
-- Cartesian product
SELECT * FROM orders o, order_items oi;
-- → 100M × 200M = 20,000 trillion rows 💥
```

#### 📊 Benchmark thực tế:

| Scenario | Rows | Index | Query time |
|----------|------|-------|------------|
| PK lookup | 100M | ✅ | < 5ms |
| Index range scan | 100M | ✅ | < 50ms (10 rows) |
| Full table scan | 100M | ❌ | 30-60s |
| Index range scan | 1M | ✅ | < 10ms |
| Full table scan | 100K | ❌ | 1-3s |

**Kết luận**: **Index đúng > Kích thước bảng**

---

### 4. Khi nào nên archive dữ liệu cũ?

#### ✅ **NÊN archive khi**:

**1. Hiếm khi truy cập** (< 1 lần/tháng)
```sql
-- Data > 2 năm: Chỉ dùng khi có audit/dispute
-- Archive sang S3 hoặc bảng riêng
```

**2. Bảng quá lớn → Query chậm**
```sql
-- orders: 100M rows → Mỗi query scan lâu
-- Archive data > 1 năm → Còn 20M rows → Nhanh hơn 5x
```

**3. Backup/restore lâu**
```sql
-- Backup 1TB: 2 giờ
-- Archive 700GB cold data
-- Backup 300GB hot data: 30 phút
```

**4. Tiết kiệm chi phí**
```sql
-- 1TB data SSD: $80/tháng
-- Archive 700GB → S3 Glacier: $2.8/tháng
-- Tiết kiệm: $77.2/tháng = $926.4/năm
```

**5. Compliance/Legal requirement**
```sql
-- Luật yêu cầu: Lưu transaction 7 năm
-- Nhưng chỉ cần truy cập khi audit
-- → Archive sau 1 năm, lưu 7 năm
```

#### ❌ **KHÔNG nên archive khi**:

**1. Vẫn truy cập thường xuyên**
```sql
-- Query "Doanh thu 6 tháng gần" mỗi ngày
-- → Cần giữ ở hot storage
```

**2. Dữ liệu nhỏ**
```sql
-- Chỉ 10GB data → Không cần archive
-- Chi phí vận hành > Chi phí tiết kiệm
```

**3. Cần real-time reporting**
```sql
-- Dashboard cần data toàn bộ lịch sử
-- Archive → Phải query 2 chỗ (hot + archive) → Chậm
```

#### 🏗️ **Chiến lược Archive**:

**Option 1: Bảng riêng**
```sql
-- Mỗi tháng chạy job
INSERT INTO orders_archive 
SELECT * FROM orders 
WHERE created_at < NOW() - INTERVAL '1 year';

DELETE FROM orders 
WHERE created_at < NOW() - INTERVAL '1 year';

-- Lợi ích: Query hot data nhanh
-- Nhược điểm: Phải JOIN khi cần data cũ
```

**Option 2: Partition (Khuyến nghị)**
```sql
-- Partition theo tháng
CREATE TABLE orders (...) PARTITION BY RANGE (created_at);

-- Detach partition cũ
ALTER TABLE orders DETACH PARTITION orders_2023_01;

-- Move sang tablespace khác (HDD hoặc S3)
ALTER TABLE orders_2023_01 SET TABLESPACE archive_storage;

-- Lợi ích: Transparent cho app
```

**Option 3: Export ra Data Lake**
```sql
-- Export sang Parquet file trên S3
COPY (
    SELECT * FROM orders 
    WHERE created_at < NOW() - INTERVAL '2 years'
) TO '/tmp/orders_2023.parquet' WITH (FORMAT PARQUET);

-- Upload lên S3
aws s3 cp /tmp/orders_2023.parquet s3://data-lake/orders/year=2023/

-- Delete từ DB
DELETE FROM orders WHERE created_at < NOW() - INTERVAL '2 years';

-- Query khi cần: Dùng Athena/Presto
```

#### 📋 **Checklist quyết định archive**:

```
☑️ Data > 1 năm tuổi
☑️ Truy cập < 1 lần/tháng
☑️ Bảng > 100GB
☑️ Query đang chậm do scan nhiều row
☑️ Có chiến lược restore khi cần
☑️ Đã test query sau khi archive
☑️ Có monitoring để phát hiện issue

→ NÊN archive!
```

---

## 🎓 Tổng kết đáp án

1. **`SELECT *`**: Lãng phí bandwidth, lộ data, không tối ưu index → **Tuyệt đối tránh trong API**

2. **Dashboard 10s vs API 10s**: Dashboard tạm OK (nhưng nên cải thiện), API **KHÔNG BAO GIỜ** được phép

3. **100M rows**: Không nhất thiết chậm nếu có **index đúng + query đúng + partition tốt**

4. **Archive**: Nên làm khi data **hiếm truy cập + bảng lớn + tiết kiệm chi phí**, nhưng cần **có chiến lược restore**

---

## 📚 Tài liệu tham khảo

- [PostgreSQL Use Cases](https://www.postgresql.org/about/)
- [AWS RDS Pricing](https://aws.amazon.com/rds/postgresql/pricing/)
- [Database Workload Patterns](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-sql-server/oltp-olap.html)

---

**🎉 Hoàn thành TASK 01! Tiếp tục → [TASK 02: Đọc schema như đọc business](task-02-read-schema.md)**
