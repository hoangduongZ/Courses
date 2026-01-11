# SQL ZERO → HERO (Enterprise) — Task-based Learning Plan

> Mục tiêu tổng: nắm chắc nền tảng → viết đúng SQL → tối ưu truy vấn → xử lý data lớn (API/Batch/Report) → đủ năng lực review & thiết kế dữ liệu theo nhu cầu doanh nghiệp.
> Sử dụng oracle
---

## TASK 01 — Hiểu “Doanh nghiệp dùng SQL để làm gì”
**Mục đích**
- Nắm bối cảnh thực tế: SQL phục vụ **giao dịch, báo cáo, phân quyền, batch**, không phải chỉ “query cho vui”.
- Phân biệt đúng hệ thống: chỗ cần nhanh (OLTP) và chỗ cần phân tích (OLAP).

**Keypoint**
- OLTP vs OLAP: khác mục tiêu, khác cách tối ưu
- SLA/latency: API vài trăm ms vs batch vài giờ
- Data lifecycle: hot/cold/archive
- Chi phí: query chậm = tốn CPU/IO/tiền và gây nghẽn hệ thống

---

## TASK 02 — Đọc schema như đọc business
**Mục đích**
- Nhìn bảng/cột/khóa là hiểu luồng nghiệp vụ; tránh join sai dẫn tới thống kê sai.

**Keypoint**
- PK/FK/Unique/Not Null
- Cardinality: 1–1, 1–N, N–N
- “Fact table” vs “Master table”
- NULL semantics: NULL ≠ 0 ≠ '' (rất hay sai)

---

## TASK 03 — SELECT tối thiểu, đúng thứ cần
**Mục đích**
- Giảm IO/network/memory: nền tảng của tối ưu.

**Keypoint**
- Tránh `SELECT *` (trừ debug)
- Chọn đúng cột, đúng kiểu dữ liệu
- Alias để query dễ đọc & maintain
- Projection ảnh hưởng performance (đặc biệt khi row wide)

---

## TASK 04 — WHERE chuẩn: lọc đúng, lọc sớm
**Mục đích**
- “Filter sớm” để giảm số row trước khi join/aggregate → nhanh hơn rõ rệt.

**Keypoint**
- AND/OR/NOT, precedence
- `IN` / `BETWEEN` / `IS NULL`
- `LIKE '%xxx%'` và rủi ro full scan
- Tránh function trên cột trong WHERE (làm mất index)

---

## TASK 05 — ORDER BY & Pagination theo chuẩn production
**Mục đích**
- Pagination sai là sát thủ performance khi data lớn.

**Keypoint**
- `ORDER BY` tốn sort (CPU + memory + temp)
- `LIMIT/OFFSET` càng lớn càng chậm (walk-through)
- Keyset pagination (seek method) khi cần performance
- Cần index đúng cho cột sort + filter

---

## TASK 06 — Aggregate & GROUP BY cho báo cáo doanh nghiệp
**Mục đích**
- Làm dashboard, KPI, thống kê “đúng số” và “chạy nổi”.

**Keypoint**
- COUNT/SUM/AVG/MIN/MAX
- `GROUP BY` vs `HAVING` vs `WHERE`
- DISTINCT: dùng đúng, tránh “chữa cháy”
- Tránh group trên dữ liệu quá lớn nếu không có chiến lược (pre-agg/materialized)

---

## TASK 07 — JOIN căn bản: đúng loại JOIN, đúng ngữ nghĩa
**Mục đích**
- 80% lỗi logic dashboard/report do JOIN sai.

**Keypoint**
- INNER vs LEFT (phổ biến nhất)
- JOIN key phải đúng (PK-FK, hoặc unique)
- Nhận diện “row multiplication” (nhân bản dữ liệu)
- Nên chọn hướng JOIN dựa trên “bảng gốc” (base set)

---

## TASK 08 — JOIN nâng cao: Filter đặt ở ON hay WHERE
**Mục đích**
- Tránh mất dữ liệu khi dùng LEFT JOIN; giữ đúng ngữ nghĩa nghiệp vụ.

**Keypoint**
- LEFT JOIN + filter sai trong WHERE → biến thành INNER JOIN
- Filter cho bảng bên phải: cân nhắc đặt trong ON
- Anti-join: “lấy những cái không có” (NOT EXISTS)
- Kiểm soát null-rejection

---

## TASK 09 — Subquery đúng chỗ: IN vs EXISTS vs JOIN
**Mục đích**
- Chọn công cụ đúng để tối ưu và giữ đúng logic.

**Keypoint**
- Subquery scalar / derived table
- Correlated subquery: mạnh nhưng dễ chậm
- `EXISTS` thường tốt cho semi-join (membership check)
- `IN` với NULL có bẫy; hiểu 3-valued logic

---

## TASK 10 — CTE (WITH): chia nhỏ logic để maintain + debug
**Mục đích**
- Query dài nhưng dễ đọc/dễ sửa; phù hợp team & hệ thống lâu năm.

**Keypoint**
- CTE để tách tầng: base → filter → join → agg
- CTE vs subquery: readability
- Một số DB có thể materialize CTE (tùy engine) → biết để tránh chậm

---

## TASK 11 — Window Functions (điểm khác biệt của mid/senior)
**Mục đích**
- Giải bài toán doanh nghiệp: top-N, running total, dedupe, phân nhóm… mà không cần nhiều subquery.

**Keypoint**
- `ROW_NUMBER/RANK/DENSE_RANK`
- `PARTITION BY` + `ORDER BY`
- Running sum/avg: `SUM() OVER (...)`
- Dedupe theo “latest record” dùng window thay vì self-join

---

## TASK 12 — Index nền tảng: tạo đúng để query dùng được
**Mục đích**
- Biết “tại sao query chậm” và “tạo index nào hiệu quả”.

**Keypoint**
- B-tree index (phổ biến)
- Composite index: thứ tự cột quan trọng (leftmost prefix)
- Covering index (index-only scan)
- Selectivity/cardinality: index không phải lúc nào cũng tốt

---

## TASK 13 — Vì sao có index mà vẫn full scan?
**Mục đích**
- Debug performance issue trong production.

**Keypoint**
- Function trên cột (UPPER/DATE/CAST) làm mất index
- Mismatch datatype (string vs number)
- Condition không tận dụng prefix của composite index
- LIKE leading wildcard `%abc`
- Statistics/optimizer misestimate (khái niệm)

---

## TASK 14 — Execution Plan: đọc plan để tối ưu có cơ sở
**Mục đích**
- Tối ưu bằng dữ liệu, không “cảm giác”.

**Keypoint**
- `EXPLAIN` / `EXPLAIN ANALYZE`
- Table scan vs index scan vs index seek
- Join algorithms: Nested Loop / Hash Join / Merge Join
- Bottleneck: rows, cost, actual time, buffers (tùy DB)

---

## TASK 15 — Query tuning playbook (thực chiến)
**Mục đích**
- Có checklist tối ưu khi API/batch chậm.

**Keypoint**
- Giảm dữ liệu càng sớm càng tốt (filter trước join)
- Trả đúng cột cần (projection)
- Tách query “đắt” khỏi đường chạy nóng
- Tránh N+1 ở tầng app (phối hợp app + SQL)

---

## TASK 16 — Transactions & Locking (để hệ thống không chết)
**Mục đích**
- Tránh deadlock, giữ dữ liệu nhất quán khi nhiều người/luồng cùng cập nhật.

**Keypoint**
- ACID cơ bản, isolation levels
- Row lock vs table lock
- Deadlock pattern + cách tránh (lock ordering, index, nhỏ transaction)
- `SELECT ... FOR UPDATE` dùng khi nào

---

## TASK 17 — Data lớn (10M–1B rows): chiến lược lưu & truy vấn
**Mục đích**
- Data tăng nhưng hệ thống vẫn chạy nổi.

**Keypoint**
- Partition (RANGE/HASH) và khi nào dùng
- Archiving & retention policy
- Hot/cold storage
- Bulk operations và giới hạn undo/redo/log (tùy DB)

---

## TASK 18 — Batch & Migration an toàn cho production
**Mục đích**
- Batch chạy ổn định, retry được, không làm sập DB.

**Keypoint**
- Chunking (limit theo id/range/time)
- Idempotency (chạy lại không hỏng)
- Upsert patterns (engine-specific)
- Monitoring: runtime, rows processed, failure handling

---

## TASK 19 — Data quality & Modeling cho doanh nghiệp
**Mục đích**
- Tối ưu không chỉ ở query, mà ở thiết kế dữ liệu.

**Keypoint**
- Normalize vs denormalize (trade-off)
- Constraints: PK/FK/unique/check
- Audit columns (created_at/updated_at/version)
- Soft delete & impact performance

---

## TASK 20 — HERO: Review & thiết kế tối ưu theo use-case
**Mục đích**
- Đủ năng lực lead: review SQL, đề xuất index/partition, thiết kế data bền vững.

**Keypoint**
- Phân loại workload: read-heavy vs write-heavy
- Thiết kế index theo query patterns (không theo cảm tính)
- Khi nào cần cache/materialized/ETL
- Khi nào SQL không phù hợp (NoSQL/search/vector/stream)

---

## DONE CRITERIA (Bạn đạt “Hero” khi)
- Đọc query đoán ngay bottleneck và hướng fix
- Viết query đúng logic + chạy nhanh + dễ maintain
- Đọc execution plan, chọn index đúng
- Xử lý batch/data lớn an toàn, retry được
- Review/thiết kế DB theo workload thực tế