# LISTAGG ... WITHIN GROUP — Oracle 5W1H

## What

`LISTAGG` là **ordered-set aggregate function** trong Oracle (từ Oracle 11g R2), gộp các giá trị của một column thành **một string duy nhất**, có separator, và **bắt buộc** chỉ định thứ tự sắp xếp qua mệnh đề `WITHIN GROUP (ORDER BY ...)`.

### Syntax

```sql
LISTAGG(measure_expr [, delimiter] [ON OVERFLOW TRUNCATE | ERROR])
  WITHIN GROUP (ORDER BY order_by_clause)
  [OVER (PARTITION BY ...)]   -- optional: dùng như analytic function
```

- `measure_expr`: cột/biểu thức cần concat.
- `delimiter`: string ngăn cách (default = không có).
- `ON OVERFLOW`: hành vi khi vượt giới hạn (Oracle 12.2+).
- `WITHIN GROUP (ORDER BY ...)`: **bắt buộc**, quyết định thứ tự nối.
- `DISTINCT`: hỗ trợ từ **Oracle 19c**.

### Return type

- `VARCHAR2` (max **4000 bytes** mặc định, hoặc **32767 bytes** nếu `MAX_STRING_SIZE = EXTENDED`).

---

## Why

- Pivot nhiều row thành 1 row dạng list trong cùng query (vd: list nhân viên theo department, list role theo user).
- Tránh N+1 query ở application layer.
- Báo cáo, view tổng hợp, export CSV-like.
- So với `WM_CONCAT` (undocumented, đã bị removed từ 12c) → `LISTAGG` là **standard, supported, deterministic**.

---

## When (khi nên / không nên dùng)

### Nên dùng
- Cardinality nhỏ trong mỗi group, độ dài chuỗi bounded.
- Cần thứ tự deterministic của các phần tử nối lại.
- Báo cáo, dashboard query (không phải hot OLTP path).

### Không nên / cần cẩn thận
- Group có quá nhiều row → dễ vượt `VARCHAR2` limit → **ORA-01489: result of string concatenation is too long**.
- Cần xử lý lại từng item ở app → nên trả về dạng nhiều row, hoặc dùng `JSON_ARRAYAGG` (Oracle 12.2+) để parse JSON an toàn hơn so với split string.
- Khi data có chứa ký tự trùng delimiter → split sai → phải chọn separator hiếm hoặc dùng JSON.

---

## Where (giới hạn cần biết)

| Vấn đề | Chi tiết |
|---|---|
| **Output limit** | `VARCHAR2` — 4000 bytes (standard) / 32767 bytes (`MAX_STRING_SIZE = EXTENDED`) |
| **Overflow error** | `ORA-01489` nếu không khai báo `ON OVERFLOW TRUNCATE` |
| **`DISTINCT`** | Chỉ có từ Oracle 19c. Bản cũ phải workaround bằng subquery |
| **`WITHIN GROUP`** | Bắt buộc — không thể bỏ như `GROUP_CONCAT` của MySQL |
| **`ORDER BY` bên trong** | Bắt buộc — nếu muốn tự do, dùng `ORDER BY NULL` (nhưng nên tránh, output không deterministic) |
| **Performance** | Aggregate giữ buffer trong PGA; group lớn có thể tốn memory đáng kể |
| **Dùng trong `WHERE`** | Không được — phải bọc subquery hoặc dùng `HAVING` |

---

## Who (so sánh với function tương đương)

| DB | Function | Note |
|---|---|---|
| **Oracle 11gR2+** | `LISTAGG` | `WITHIN GROUP` bắt buộc, `DISTINCT` từ 19c |
| **MySQL / MariaDB** | `GROUP_CONCAT` | `ORDER BY` optional, có `DISTINCT`, giới hạn bởi `group_concat_max_len` |
| **PostgreSQL** | `STRING_AGG` | `ORDER BY` optional bên trong call |
| **SQL Server 2017+** | `STRING_AGG` | `WITHIN GROUP (ORDER BY ...)` optional |
| **DB2** | `LISTAGG` | Syntax gần giống Oracle |
| **Cross-DB safer alternative** | `JSON_ARRAYAGG` | Có ở Oracle 12.2+, MySQL 5.7.22+, PostgreSQL, SQL Server 2022+ |

---

## How

### 1. Basic

```sql
SELECT department_id,
       LISTAGG(employee_name, ', ') WITHIN GROUP (ORDER BY employee_name) AS employees
FROM   employees
GROUP  BY department_id;

-- 10 | "Alice, Bob, Charlie"
-- 20 | "David, Eve"
```

### 2. Với `DISTINCT` (Oracle 19c+)

```sql
SELECT department_id,
       LISTAGG(DISTINCT job_title, ' | ') WITHIN GROUP (ORDER BY job_title) AS jobs
FROM   employees
GROUP  BY department_id;
```

**Workaround cho version < 19c:**

```sql
SELECT department_id,
       LISTAGG(job_title, ' | ') WITHIN GROUP (ORDER BY job_title) AS jobs
FROM   (SELECT DISTINCT department_id, job_title FROM employees)
GROUP  BY department_id;
```

### 3. `ON OVERFLOW TRUNCATE` (Oracle 12.2+) — production-safe pattern

```sql
SELECT department_id,
       LISTAGG(employee_name, ', '
               ON OVERFLOW TRUNCATE '...(more)' WITH COUNT)
         WITHIN GROUP (ORDER BY employee_name) AS employees
FROM   employees
GROUP  BY department_id;

-- Khi vượt 4000 bytes:
-- "Alice, Bob, ...(more)(125)"
--                              ^^^^^ số item còn lại bị cắt
```

**Options của `ON OVERFLOW`:**
- `ON OVERFLOW ERROR` (default) — raise `ORA-01489`.
- `ON OVERFLOW TRUNCATE` — cắt và thêm indicator (default `'...'`).
- `WITH COUNT` / `WITHOUT COUNT` — hiển thị số item bị cắt hay không.

### 4. Analytic mode (window function) — không cần `GROUP BY`

```sql
SELECT employee_id,
       department_id,
       employee_name,
       LISTAGG(employee_name, ', ')
         WITHIN GROUP (ORDER BY employee_name)
         OVER (PARTITION BY department_id) AS dept_members
FROM   employees;

-- Giữ nguyên số row, mỗi row có cột list cả phòng ban
```

### 5. Detect overflow nguy hiểm

```sql
SELECT department_id,
       LISTAGG(employee_name, ',') WITHIN GROUP (ORDER BY employee_name) AS list,
       COUNT(*) AS actual_cnt,
       LENGTHB(LISTAGG(employee_name, ',') WITHIN GROUP (ORDER BY employee_name)) AS byte_len
FROM   employees
GROUP  BY department_id
HAVING LENGTHB(LISTAGG(employee_name, ',') WITHIN GROUP (ORDER BY employee_name)) > 3900;
```

### 6. Alternative an toàn hơn — `JSON_ARRAYAGG` (Oracle 12.2+)

```sql
SELECT department_id,
       JSON_ARRAYAGG(employee_name ORDER BY employee_name) AS employees_json
FROM   employees
GROUP  BY department_id;

-- 10 | ["Alice","Bob","Charlie"]
-- Parse JSON ở app → không lo separator collision, không lo escape
```

### 7. Gotchas thường gặp

1. **`ORA-01489` silent killer**: Bản < 12.2 không có `ON OVERFLOW TRUNCATE` → query đang chạy ổn, đến khi data tăng thì crash production. Phải bọc `XMLAGG` workaround:
   ```sql
   -- Workaround cho Oracle < 12.2 khi muốn tránh ORA-01489
   SELECT department_id,
          RTRIM(XMLAGG(XMLELEMENT(E, employee_name, ',').EXTRACT('//text()')
                       ORDER BY employee_name).GetClobVal(), ',') AS employees
   FROM   employees
   GROUP  BY department_id;
   -- Trả về CLOB → không bị 4000-byte limit
   ```

2. **NULL bị loại**: `LISTAGG` ignore NULL. Muốn giữ → `NVL(col, '(null)')` trước.

3. **`WITHIN GROUP (ORDER BY NULL)`**: hợp lệ về syntax nhưng output **không deterministic** giữa các lần chạy → flaky test.

4. **Delimiter collision**: data chứa `,` → split sai. Dùng separator hiếm như `CHR(31)` (Unit Separator) hoặc chuyển `JSON_ARRAYAGG`.

5. **`LENGTH` vs `LENGTHB`**: Khi check overflow, dùng `LENGTHB` (bytes) vì limit là byte-based, không phải char-based — đặc biệt với multi-byte charset (UTF-8).

---

## Summary table — Oracle version compatibility

| Feature | Min version |
|---|---|
| `LISTAGG ... WITHIN GROUP` | 11g Release 2 |
| `ON OVERFLOW TRUNCATE / ERROR` | 12c Release 2 (12.2) |
| `DISTINCT` keyword | 19c |
| `JSON_ARRAYAGG` (alternative) | 12c Release 2 (12.2) |