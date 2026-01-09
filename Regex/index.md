# Regex “không thừa không thiếu” (Enterprise) — Zero → Ready

> Mục tiêu: dùng Regex **đủ để đi làm**: tìm kiếm log/code, validate input cơ bản, trích xuất dữ liệu, thay thế hàng loạt, và tránh bẫy performance.
>
> Nguyên tắc: ưu tiên **đọc/viết được** + **an toàn** + **maintainable**.
> Có lý thuyết base trước khi đi vào các phần tiếp theo
---

## Task 1 — Hiểu regex là gì và dùng khi nào (đúng bài toán)
**Mục đích:** Không lạm dụng regex; biết lúc nào regex phù hợp nhất.

**Keypoint cần học**
- Regex = pattern để match string
- Use-case enterprise: search log, parse text, validate input, refactor replace
- Khi không nên dùng: parse HTML phức tạp, logic nhiều nhánh → dùng parser/thư viện
- “Regex là tool”, không phải giải pháp mọi thứ

**Bài tập**
- Chọn 3 case công việc: (1) tìm log error, (2) lấy email, (3) đổi format date trong file → ghi pattern dự kiến.

---

## Task 2 — Literal match & metacharacters (cú pháp tối thiểu)
**Mục đích:** Biết ký tự nào “bình thường”, ký tự nào “đặc biệt”.

**Keypoint**
- Match đúng chuỗi: `abc`
- Metacharacters phổ biến: `. ^ $ * + ? ( ) [ ] { } \ |`
- Escape: `\.` để match dấu chấm thật
- OR: `a|b` (ưu tiên theo nhóm)

**Bài tập**
- Match đúng chuỗi `v1.2.3` (lưu ý dấu `.`) → dùng escape.

---

## Task 3 — Character classes (nhóm ký tự) — dùng rất nhiều
**Mục đích:** Match theo “loại ký tự” thay vì liệt kê dài.

**Keypoint**
- `[abc]`, `[a-z]`, `[0-9]`
- Negation: `[^0-9]` (không phải số)
- Shortcuts: `\d` (digit), `\w` (word), `\s` (space)  
  (lưu ý: `\w` = chữ/số/underscore, không phải “mọi ký tự unicode”)
- Dấu `-` trong `[]` có ý nghĩa range

**Bài tập**
- Match mã đơn hàng kiểu `ORD-2026-000123` bằng class + range.

---

## Task 4 — Quantifiers (lặp) — nền của validate/parse
**Mục đích:** Kiểm soát số lần xuất hiện.

**Keypoint**
- `*` (0+), `+` (1+), `?` (0/1)
- `{n}`, `{n,}`, `{n,m}`
- Greedy vs lazy: `.*` vs `.*?` (cực quan trọng khi parse)
- Tránh `.*` bừa bãi

**Bài tập**
- Match số điện thoại 10–11 chữ số: `\d{10,11}` (tối thiểu).

---

## Task 5 — Anchors & boundaries (match đúng vị trí)
**Mục đích:** Tránh match “lọt” trong chuỗi dài.

**Keypoint**
- `^` bắt đầu dòng, `$` cuối dòng
- Word boundary: `\b` (tách từ)
- Multiline mode (khái niệm): `^/$` theo từng dòng
- Dùng anchor để validate: `^...$`

**Bài tập**
- Validate “chỉ toàn số”: `^\d+$` (nếu thiếu ^$ sẽ match một phần).

---

## Task 6 — Grouping & capturing (trích xuất dữ liệu)
**Mục đích:** Lấy được “phần bạn cần” từ chuỗi.

**Keypoint**
- Group: `( ... )`
- Capturing groups: lấy giá trị nhóm
- Non-capturing: `(?: ... )` (để nhóm mà không capture)
- Named groups (tùy engine): `(?<name>...)` hoặc `(?P<name>...)`  
  (biết để đọc code enterprise)

**Bài tập**
- Trích xuất `year-month-day` từ `2026-01-08` thành 3 nhóm.

---

## Task 7 — Alternation & optional parts (pattern thực tế)
**Mục đích:** Viết regex chịu được nhiều format hợp lệ.

**Keypoint**
- `A|B|C`
- Group + OR: `(?:GET|POST)`
- Optional group: `(?:-dev)?`
- Ưu tiên đọc được (đừng nhồi quá phức tạp)

**Bài tập**
- Match endpoint `/api/v1` hoặc `/api/v2`: `^/api/v(?:1|2)\b`

---

## Task 8 — Lookarounds (mức đủ dùng enterprise)
**Mục đích:** Match theo “ngữ cảnh” mà không lấy vào kết quả.

**Keypoint**
- Positive lookahead: `(?=...)`
- Negative lookahead: `(?!...)`
- Positive lookbehind: `(?<=...)` (tùy engine)
- Negative lookbehind: `(?<!...)`
- Dùng để: “có X phía sau” nhưng không ăn vào match

**Bài tập**
- Match `ERROR` nhưng không match `ERROR_CODE`: `\bERROR\b(?!_)`

---

## Task 9 — Replace & refactor (thay thế hàng loạt)
**Mục đích:** Dùng regex để refactor text/code/log nhanh.

**Keypoint**
- Replace dựa trên group: `$1`, `\1` (tùy tool)
- Named group replace: `${name}` (tùy tool)
- “Find/Replace” trong IDE vs sed khác syntax (nhận biết)
- Luôn test trên sample trước khi apply toàn bộ

**Bài tập**
- Đổi `2026/01/08` → `2026-01-08` bằng group + replace.

---

## Task 10 — Regex cho validation (đúng mức enterprise)
**Mục đích:** Validate input cơ bản nhưng không “ảo tưởng regex giải quyết hết”.

**Keypoint**
- Email: regex chỉ nên “basic”, không cố cover toàn RFC
- Password policy: regex chỉ check pattern, vẫn cần rule khác
- Phone/ID: validate format + server-side validation
- Always anchor: `^...$`
- Tránh regex quá dài gây khó maintain

**Bài tập**
- Validate username: chữ/số/underscore, 3–20 ký tự: `^[A-Za-z0-9_]{3,20}$`

---

## Task 11 — Performance & ReDoS (enterprise bắt buộc biết)
**Mục đích:** Tránh regex gây treo server (catastrophic backtracking).

**Keypoint**
- Dấu hiệu nguy hiểm: nested quantifiers như `(a+)+`, `(.+)+`, `(.*a)*`
- Ưu tiên pattern cụ thể hơn thay vì `.*`
- Giới hạn input length trước khi regex (important)
- Dùng engine có timeout/limits (nếu có)

**Bài tập**
- Nhận diện vì sao `^(a+)+$` nguy hiểm khi input là `aaaaaaaaaaaaab`.

---

## Task 12 — “Hero checklist” (đủ dùng enterprise)
**Mục đích:** Tự kiểm tra bạn đã “regex-ready” chưa.

**Keypoint**
- Match/escape metacharacters đúng
- Dùng class + quantifier + anchors thành thạo
- Trích xuất bằng groups, replace bằng backreference
- Biết dùng lazy vs greedy đúng chỗ
- Dùng lookaround ở mức cơ bản khi cần
- Tránh regex khó đọc và tránh bẫy ReDoS
- Luôn có sample tests trước khi apply production

---
