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

## 📚 Tài liệu tham khảo

- [PostgreSQL Use Cases](https://www.postgresql.org/about/)
- [AWS RDS Pricing](https://aws.amazon.com/rds/postgresql/pricing/)
- [Database Workload Patterns](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-sql-server/oltp-olap.html)

---

**🎉 Hoàn thành TASK 01! Tiếp tục → [TASK 02: Đọc schema như đọc business](task-02-read-schema.md)**
