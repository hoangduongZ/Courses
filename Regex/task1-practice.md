# Task 1 — Hiểu regex là gì và dùng khi nào (đúng bài toán)

---

## 📚 PHẦN 1: LÝ THUYẾT CƠ BẢN

### 1.1. Regex là gì?

**Regex** (Regular Expression) = **Pattern** (khuôn mẫu) để **match** (khớp) với **text** (chuỗi ký tự).

#### Ví dụ đời thường:
Bạn vào siêu thị tìm "táo":
- **Tìm đơn giản:** Tìm từ "táo" → chỉ match "táo"
- **Tìm pattern:** Tìm "bất kỳ loại táo nào" → match "táo đỏ", "táo xanh", "táo Mỹ"

Regex cũng vậy:
- **Tìm đơn giản:** Tìm từ "ERROR" → chỉ match "ERROR"  
- **Tìm pattern:** Tìm `ERROR|FATAL|Exception` → match cả 3 loại lỗi

#### So sánh Ctrl+F vs Regex:

| Công việc | Ctrl+F | Regex |
|-----------|--------|-------|
| Tìm từ "ERROR" | ✅ OK | ✅ OK |
| Tìm "ERROR" hoặc "FATAL" | ❌ Phải search 2 lần | ✅ 1 lần: `ERROR\|FATAL` |
| Tìm số điện thoại (10 chữ số) | ❌ Không làm được | ✅ `\d{10}` |
| Tìm tất cả email | ❌ Không làm được | ✅ `...@...\.com` |
| Đổi format date hàng loạt | ❌ Phải viết code | ✅ Find + Replace |

**Kết luận:** Regex = Ctrl+F nâng cao, có thể tìm theo "khuôn mẫu" thay vì từ cố định.

---

### 1.2. Khi nào NÊN dùng Regex?

#### ✅ Use case 1: Tìm kiếm log/code
**Tình huống:** File log 50,000 dòng, tìm tất cả lỗi

```bash
# Không dùng regex - phải search nhiều lần
grep "ERROR" app.log
grep "FATAL" app.log  
grep "Exception" app.log

# Dùng regex - 1 lần xong
grep -E "(ERROR|FATAL|Exception)" app.log
```

#### ✅ Use case 2: Extract data (trích xuất dữ liệu)
**Tình huống:** Lấy tất cả email từ file text

```python
# Không dùng regex - phải viết nhiều logic
text = "Contact: abc@gmail.com or xyz@company.vn"
# Phải split, tìm @, check .com, check format...
# Code dài 20-30 dòng

# Dùng regex - 2 dòng xong
import re
emails = re.findall(r'[\w.+-]+@[\w.-]+\.\w+', text)
```

#### ✅ Use case 3: Validate input
**Tình huống:** User nhập username, chỉ cho phép chữ/số/underscore, 3-20 ký tự

```python
# Không dùng regex - nhiều if
def validate(name):
    if len(name) < 3 or len(name) > 20:
        return False
    for char in name:
        if not (char.isalnum() or char == '_'):
            return False
    return True

# Dùng regex - 1 dòng
import re
def validate(name):
    return bool(re.match(r'^[A-Za-z0-9_]{3,20}$', name))
```

#### ✅ Use case 4: Refactor/Replace hàng loạt
**Tình huống:** 100 file, đổi tất cả `DD/MM/YYYY` → `YYYY-MM-DD`

- **Không dùng regex:** Viết script phức tạp, parse từng dòng
- **Dùng regex:** VS Code Find/Replace → 5 giây xong

---

### 1.3. Khi nào KHÔNG NÊN dùng Regex?

#### ❌ Parse HTML/XML
**Tại sao không?**

```html
<div class="user">
  <div class="info">
    <span>John</span>
  </div>
</div>
```

HTML có thể:
- Nested bất kỳ: `<div><div><div>...</div></div></div>`
- Nhiều attributes: `<div class="a" id="b" data-x="c">`
- Whitespace tùy ý
- Self-closing tags: `<img />`, `<br>`

→ Regex để parse HTML sẽ rất dài, dễ sai, không maintainable

**Nên dùng gì?**
```python
from bs4 import BeautifulSoup
soup = BeautifulSoup(html, 'html.parser')
name = soup.select_one('.user .info span').text  # Dễ đọc, chính xác
```

#### ❌ Logic phức tạp nhiều nhánh
**Ví dụ:** Password phải có 1 chữ hoa, 1 chữ thường, 1 số, 1 ký tự đặc biệt

```regex
# Regex này WORK nhưng CỰC khó đọc
^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,20}$
```

**Vấn đề:**
- Khó đọc, khó hiểu
- Khó debug khi sai
- Khó sửa khi thêm rule mới
- Đồng nghiệp không hiểu code của bạn

**Nên làm thế nào?**
```python
def validate_password(pwd):
    errors = []
    if len(pwd) < 8 or len(pwd) > 20:
        errors.append("Length must be 8-20")
    if not re.search(r'[a-z]', pwd):
        errors.append("Need lowercase letter")
    if not re.search(r'[A-Z]', pwd):
        errors.append("Need uppercase letter")
    if not re.search(r'\d', pwd):
        errors.append("Need digit")
    if not re.search(r'[@$!%*?&]', pwd):
        errors.append("Need special char")
    return len(errors) == 0, errors
```

→ Dễ đọc, dễ maintain, dễ mở rộng, có message lỗi rõ ràng

---

### 1.4. Quy tắc vàng khi dùng Regex

#### 1. "Regex là tool, không phải giải pháp cho mọi thứ"
- Dùng đúng chỗ: search, extract, validate đơn giản
- Không dùng: parse phức tạp, logic nhiều nhánh

#### 2. "Regex quá 2-3 dòng → sai tool rồi"
- Regex dài = khó đọc = khó maintain = bug
- Nếu pattern quá phức tạp → cân nhắc dùng parser/code thường

#### 3. "Luôn test trước khi apply production"
- Dùng regex101.com để test
- Test với sample data đa dạng
- Test edge case: empty, special chars, unicode

#### 4. "Basic validation > Perfect validation"
```python
# ❌ Perfect email regex (theo RFC 5322) - KHÔNG NÊN
r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'

# ✅ Basic email regex - NÊN DÙNG
r'[\w.+-]+@[\w.-]+\.\w+'
```

Tại sao basic > perfect?
- Cover được 95% case thực tế
- Dễ đọc, dễ maintain
- Email "perfect" theo RFC rất hiếm gặp (ví dụ: `"John Doe"@example.com`)
- Vẫn cần server-side validation (gửi email xác nhận)

---

### 1.5. Tools để học và practice Regex

#### Online Testers (quan trọng!)
1. **regex101.com** ⭐⭐⭐⭐⭐ (recommend nhất)
   - Giải thích từng ký tự trong pattern
   - Có quick reference
   - Support nhiều ngôn ngữ: Python, JavaScript, Java, PHP, Go
   - Hiện group captures
   - Test substitution (replace)

2. **regexr.com**
   - UI đẹp, trực quan
   - Có cheatsheet tích hợp
   - Visualize pattern

3. **regexpal.com**
   - Đơn giản, nhanh, lightweight

#### Trong công việc hàng ngày
- **VS Code:** `Ctrl+F` → click icon `.*` để bật regex mode
- **Terminal:** `grep -E "pattern" file.log`
- **Chrome DevTools:** `Ctrl+Shift+F` trong tab Sources
- **Database:** SQL có clause `REGEXP` hoặc `RLIKE`

---

### 1.6. Mindset học Regex đúng cách

#### ❌ Sai lầm thường gặp:
- Học thuộc tất cả ký tự đặc biệt: `. ^ $ * + ? [ ] { } ( ) | \`
- Cố gắng viết regex "perfect" ngay từ đầu
- Sợ regex vì trông "rối mắt"

#### ✅ Cách học đúng:
1. **Học theo use-case, không học thuộc**
   - Cần tìm số → học `\d`, `[0-9]`, `{n,m}`
   - Cần tìm email → học `+`, `.`, `*`
   - Cần validate → học `^`, `$`

2. **Bắt đầu từ đơn giản → phức tạp**
   ```regex
   # Bước 1: Match "error" đơn giản
   error
   
   # Bước 2: Match ERROR hoặc error (case insensitive)
   [Ee][Rr][Rr][Oo][Rr]
   
   # Bước 3: Match ERROR/FATAL/Exception
   ERROR|FATAL|Exception
   
   # Bước 4: Chỉ match từ hoàn chỉnh
   \b(ERROR|FATAL|Exception)\b
   ```

3. **Google/ChatGPT là bạn**
   - Không nhớ syntax → Google: "regex match email"
   - Pattern không work → paste vào regex101.com để debug
   - 20% case phức tạp → hỏi AI/cộng đồng

---

### 1.7. Checklist tự kiểm tra - Bạn đã hiểu chưa?

Trả lời 5 câu hỏi sau:

1. **Regex là gì?** (trả lời bằng 1 câu)
   <details>
   <summary>Đáp án</summary>
   Regex là pattern để match/tìm kiếm text theo khuôn mẫu
   </details>

2. **Kể 3 use-case NÊN dùng regex**
   <details>
   <summary>Đáp án</summary>
   - Search log/code
   - Extract data (email, phone, date)
   - Validate input đơn giản
   - Refactor/Replace hàng loạt
   </details>

3. **Kể 2 use-case KHÔNG NÊN dùng regex**
   <details>
   <summary>Đáp án</summary>
   - Parse HTML/XML phức tạp
   - Logic nhiều nhánh/rule phức tạp
   </details>

4. **"Regex là tool, không phải _____?"**
   <details>
   <summary>Đáp án</summary>
   Giải pháp cho mọi thứ / ngôn ngữ lập trình / magic
   </details>

5. **Website nào để test regex?**
   <details>
   <summary>Đáp án</summary>
   regex101.com (recommend nhất)
   </details>

**Nếu trả lời được 4/5 câu → OK, đi tiếp phần bài tập!**

---

## 📝 PHẦN 2: BÀI TẬP THỰC HÀNH

Bây giờ bạn đã hiểu lý thuyết, hãy áp dụng vào 3 case thực tế dưới đây.

### Case 1: Tìm log error trong file

### Mô tả bài toán
Bạn là backend developer, hệ thống có file log `app.log` với 50,000 dòng. Sếp yêu cầu tìm tất cả dòng có lỗi để debug.

### Sample data
```
2026-01-08 10:23:45 [INFO] User login successful - user_id: 12345
2026-01-08 10:24:12 [ERROR] Database connection timeout - db: main
2026-01-08 10:24:15 [FATAL] System out of memory - heap size exceeded
2026-01-08 10:24:20 [WARN] Slow query detected - 3.2s
2026-01-08 10:24:25 [ERROR] Failed to send email - SMTP error
2026-01-08 10:24:30 [INFO] Cache cleared successfully
2026-01-08 10:24:35 Exception in thread "main" java.lang.NullPointerException
```

### ✅ Pattern dự kiến
```regex
\b(ERROR|FATAL|Exception)\b
```

### Giải thích pattern
- `\b` = word boundary (đảm bảo match từ hoàn chỉnh, không match "ERRORS" hay "ERROR_CODE")
- `ERROR|FATAL|Exception` = match một trong 3 từ khóa
- `\b` = word boundary cuối

### Test trên regex101.com
Paste pattern và sample data vào [regex101.com](https://regex101.com)

**Kết quả match:**
- ✅ `ERROR` ở dòng 2
- ✅ `FATAL` ở dòng 3
- ✅ `ERROR` ở dòng 5
- ✅ `Exception` ở dòng 7

**Không match:**
- ❌ `INFO` (không phải error)
- ❌ `WARN` (chỉ warning, không phải error nghiêm trọng)

### Áp dụng thực tế
```bash
# Trong terminal
grep -E "\b(ERROR|FATAL|Exception)\b" app.log

# Hoặc trong VS Code
# Ctrl+F → bật regex mode (.*) → nhập pattern trên
```

---

## 📧 Case 2: Lấy email từ text

### Mô tả bài toán
Marketing team gửi bạn 1 file text với thông tin khách hàng lộn xộn. Bạn cần extract tất cả email để import vào CRM.

### Sample data
```
Liên hệ: support@company.com hoặc sales@company.vn
Admin: admin_dev@test-server.co.uk
CEO email là ceo123@startup.io
Hotline: 1900-xxxx hoặc info@help-center.com.vn
Invalid: @missing.com, no-at-sign.com, spaces @bad.com
```

### ✅ Pattern dự kiến
```regex
[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}
```

### Giải thích pattern từng phần
1. `[A-Za-z0-9._%+-]+`
   - Match phần username
   - Chữ hoa, chữ thường, số, và các ký tự: `._%+-`
   - `+` = 1 hoặc nhiều ký tự

2. `@`
   - Ký tự @ bắt buộc

3. `[A-Za-z0-9.-]+`
   - Match tên domain
   - Chữ, số, dấu `.` và `-`

4. `\.[A-Za-z]{2,}`
   - `\.` = dấu chấm literal (escape)
   - `[A-Za-z]{2,}` = extension tối thiểu 2 ký tự (.com, .vn, .io, .co.uk)

### Test trên regex101.com
**Kết quả match:**
- ✅ `support@company.com`
- ✅ `sales@company.vn`
- ✅ `admin_dev@test-server.co.uk`
- ✅ `ceo123@startup.io`
- ✅ `info@help-center.com.vn`

**Không match (đúng):**
- ❌ `@missing.com` (thiếu username)
- ❌ `no-at-sign.com` (thiếu @)
- ❌ `spaces @bad.com` (có space trước @)

### ⚠️ Lưu ý Enterprise
- Pattern này **KHÔNG** cover 100% RFC 5322 (email spec đầy đủ)
- Đủ cho 95% case thực tế: extract email từ text/log
- Email phức tạp kiểu `"John Doe"@example.com` không match → OK, vì hiếm gặp
- **Luôn validate thêm ở server-side** (gửi email xác nhận)

### Áp dụng thực tế
```python
import re

text = "Contact: support@company.com or sales@company.vn"
emails = re.findall(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', text)
print(emails)
# Output: ['support@company.com', 'sales@company.vn']
```

---

## 📅 Case 3: Đổi format date trong file

### Mô tả bài toán
Team nhận database export từ hệ thống cũ, tất cả date ở format `DD/MM/YYYY`. Hệ thống mới cần format `YYYY-MM-DD` để import. Có 100 file, 10,000 dòng/file.

### Sample data
```
Release date: 08/01/2026
Deadline: 31/12/2025
Start: 01/06/2024, End: 30/09/2024
Invoice date 25/08/2023 - Payment due 25/09/2023
```

### ✅ Pattern để tìm (Find)
```regex
(\d{2})/(\d{2})/(\d{4})
```

### ✅ Pattern để thay (Replace)
```regex
$3-$2-$1
```

### Giải thích pattern
**Find pattern:**
- `(\d{2})` = capture 2 chữ số (day) → group 1
- `/` = dấu gạch chéo literal
- `(\d{2})` = capture 2 chữ số (month) → group 2
- `/` = dấu gạch chéo literal
- `(\d{4})` = capture 4 chữ số (year) → group 3

**Replace pattern:**
- `$3` = lấy group 3 (year)
- `-` = dấu gạch ngang
- `$2` = lấy group 2 (month)
- `-` = dấu gạch ngang
- `$1` = lấy group 1 (day)

### Ví dụ cụ thể
| Input | Group 1 | Group 2 | Group 3 | Output |
|-------|---------|---------|---------|--------|
| `08/01/2026` | `08` | `01` | `2026` | `2026-01-08` |
| `31/12/2025` | `31` | `12` | `2025` | `2025-12-31` |
| `01/06/2024` | `01` | `06` | `2024` | `2024-06-01` |

### Test trên regex101.com
1. Paste sample data
2. Nhập Find pattern: `(\d{2})/(\d{2})/(\d{4})`
3. Chuyển sang tab "Substitution"
4. Nhập Replace: `$3-$2-$1`
5. Xem kết quả Preview

**Kết quả sau replace:**
```
Release date: 2026-01-08
Deadline: 2025-12-31
Start: 2024-06-01, End: 2024-09-30
Invoice date 2023-08-25 - Payment due 2023-09-25
```

### ⚠️ Lưu ý quan trọng
1. **Pattern này KHÔNG validate date hợp lệ**
   - `99/99/9999` vẫn match
   - `32/13/2024` vẫn match
   - Nếu cần validate, phải thêm logic riêng

2. **Có thể match nhầm**
   - Version: `v1.2.3` có dạng `x/x/xxxx` không?
   - IP: `192.168.1.1` có dạng `xx/xx/xxxx` không?
   - Trong case này: NO, vì có 4 chữ số ở cuối

3. **Luôn test trước trên sample nhỏ!**
   - Chọn 10-20 dòng
   - Test replace
   - Verify kết quả
   - Mới apply toàn bộ

### Áp dụng thực tế

#### Trong VS Code:
1. Mở file
2. `Ctrl+H` (Find and Replace)
3. Bật regex mode (click icon `.*`)
4. Find: `(\d{2})/(\d{2})/(\d{4})`
5. Replace: `$3-$2-$1`
6. **Replace one by one** để kiểm tra (Alt+R)
7. Nếu OK → `Replace All` (Ctrl+Alt+Enter)

#### Trong Python:
```python
import re

def convert_date_format(text):
    pattern = r'(\d{2})/(\d{2})/(\d{4})'
    replacement = r'\3-\2-\1'  # Python dùng \1, \2, \3
    return re.sub(pattern, replacement, text)

# Test
text = "Release date: 08/01/2026"
result = convert_date_format(text)
print(result)  # Output: Release date: 2026-01-08
```

#### Trong Terminal (sed):
```bash
# Backup file trước
cp data.txt data.txt.backup

# Replace
sed -E 's/([0-9]{2})\/([0-9]{2})\/([0-9]{4})/\3-\2-\1/g' data.txt
```

---

## 📊 Tổng kết Task 1

### ✅ Đã hoàn thành
- [x] Hiểu regex là gì (pattern match string)
- [x] Biết 3 use-case chính: search log, extract data, refactor replace
- [x] Viết được pattern cơ bản cho 3 case thực tế
- [x] Biết test pattern trên regex101.com
- [x] Biết áp dụng vào công cụ: VS Code, Python, Terminal

### 🎯 Key takeaways
1. **Regex là tool** - dùng đúng chỗ, không lạm dụng
2. **Pattern cơ bản** - không cần phức tạp, đủ để solve bài toán
3. **Luôn test trước** - tránh replace sai hàng loạt
4. **Không validate 100%** - regex chỉ check format, cần logic thêm

### 🚀 Next steps
Khi bạn đã tự tin với 3 pattern trên:
- ✅ Sang **Task 2** - học về metacharacters và escape
- ✅ Practice thêm với data thực tế của công việc
- ✅ Bookmark regex101.com để dùng hàng ngày

---

## 💡 Bài tập tự luyện (optional)

Thử tự viết pattern cho các case sau:

1. **Tìm số điện thoại VN**
   - Format: `0123456789` hoặc `0123-456-789` hoặc `0123 456 789`
   - Hint: 10-11 chữ số, bắt đầu bằng 0

2. **Extract URL từ text**
   - Match: `https://example.com`, `http://test.vn`
   - Hint: `https?://...`

3. **Tìm mã đơn hàng**
   - Format: `ORD-2026-000123`, `INV-2025-999999`
   - Hint: 3 chữ cái - 4 số - 6 số

Đáp án sẽ có ở các Task sau! 😊
