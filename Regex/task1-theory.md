# Task 1 — Lý Thuyết Regex Từ Con Số 0

> **Mục tiêu:** Hiểu regex từ cơ bản nhất, giải thích từng ký tự, từng khái niệm một cách dễ hiểu nhất có thể.

---

## 📖 PHẦN 1: REGEX LÀ GÌ? (Giải thích cho người hoàn toàn mới)

### 1.1. Bắt đầu từ tìm kiếm đơn giản

Bạn biết chức năng **Ctrl+F** (Find) chứ? Ví dụ:

```
Text: "Tôi thích táo. Táo rất ngon. Táo đỏ và táo xanh."
Tìm: "táo"
```

Kết quả: Chỉ tìm được từ "táo" (chữ thường), không tìm được "Táo" (chữ hoa).

### 1.2. Vậy Regex khác gì?

**Regex = Tìm kiếm thông minh** - Tìm theo "khuôn mẫu" chứ không phải từ cố định.

```
Text: "Tôi thích táo. Táo rất ngon. Táo đỏ và táo xanh."
Regex: "[Tt]áo"
```

Kết quả: Tìm được CẢ "táo" VÀ "Táo" trong một lần tìm!

**Giải thích:**
- `[Tt]` = "Chữ T hoặc chữ t đều được"
- `áo` = "Theo sau là chữ á và o"

### 1.3. Ví dụ thực tế dễ hiểu

#### Ví dụ 1: Tìm số điện thoại
```
Text: "Liên hệ: 0123456789 hoặc 0987654321"
Ctrl+F: Phải gõ chính xác từng số → mỗi lần tìm 1 số
Regex: "\d{10}" → Tìm "bất kỳ 10 chữ số liên tiếp nào"
```

#### Ví dụ 2: Tìm email
```
Text: "Email: abc@gmail.com hoặc xyz@yahoo.vn"
Ctrl+F: Phải gõ chính xác "abc@gmail.com" → chỉ tìm được 1 email
Regex: "\w+@\w+\.\w+" → Tìm "bất kỳ email nào"
```

**Kết luận:** Regex giúp bạn tìm theo "dạng" thay vì "từ cụ thể".

---

## 🔤 PHẦN 2: CÁC KÝ TỰ CƠ BẢN (Từng ký tự một!)

### 2.1. Ký tự thường (Literal Characters)

**Đây là cái đơn giản nhất!**

Nếu bạn gõ chữ bình thường trong regex → nó tìm chính xác chữ đó.

```regex
hello
```
- Tìm chữ "hello" trong text
- Giống hệt Ctrl+F

**Ví dụ:**
```
Text: "Say hello to my friend"
Regex: "hello"
Match: "Say hello to my friend"
            ^^^^^
```

### 2.2. Dấu chấm `.` (Dot) - Ký tự bất kỳ

**Dấu chấm `.` = "1 ký tự bất kỳ nào cũng được"**

```regex
h.t
```
- `h` = chữ h
- `.` = **1 ký tự bất kỳ** (chữ, số, ký tự đặc biệt, khoảng trắng)
- `t` = chữ t

**Ví dụ:**
```
Text: "hat, hot, hit, h9t, h@t, h t"
Regex: "h.t"
Match: "hat", "hot", "hit", "h9t", "h@t", "h t"
```

**Giải thích kỹ hơn:**
- `hat` → h + a + t → MATCH ✅
- `hot` → h + o + t → MATCH ✅
- `hit` → h + i + t → MATCH ✅
- `h9t` → h + 9 + t → MATCH ✅
- `h@t` → h + @ + t → MATCH ✅
- `h t` → h + (space) + t → MATCH ✅

### 2.3. Dấu ngã `\d` - Chữ số (Digit)

**`\d` = "1 chữ số từ 0-9"**

```regex
\d
```
- Match: `0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`
- Không match: chữ cái, ký tự đặc biệt

**Ví dụ:**
```
Text: "Tôi có 5 táo, 10 cam và 3 ổi"
Regex: "\d"
Match: "Tôi có 5 táo, 10 cam và 3 ổi"
             ^   ^^       ^
```

**So sánh với dấu chấm:**
```
Regex: "."  → Match mọi ký tự (chữ, số, space, @, #...)
Regex: "\d" → Chỉ match số 0-9
```

### 2.4. Dấu `\D` - KHÔNG phải chữ số

**`\D` = "1 ký tự KHÔNG phải số"**

```regex
\D
```
- Match: chữ cái, khoảng trắng, ký tự đặc biệt
- Không match: 0-9

**Ví dụ:**
```
Text: "abc123xyz"
Regex: "\D"
Match: "abc123xyz"
        ^^^   ^^^
```

**Ghi nhớ:**
- `\d` (chữ thường) = chữ số
- `\D` (chữ HOA) = KHÔNG phải chữ số

### 2.5. Dấu `\w` - Ký tự từ (Word character)

**`\w` = "1 ký tự chữ, số hoặc gạch dưới"**

Chi tiết: `\w` match:
- Chữ cái: `a-z`, `A-Z`
- Số: `0-9`
- Gạch dưới: `_`

**Ví dụ:**
```
Text: "user_123 @admin hello-world"
Regex: "\w"
Match: "user_123 @admin hello-world"
        ^^^^^^^^  ^^^^^  ^^^^^ ^^^^^
```

**Giải thích từng phần:**
- `user_123` → 8 ký tự đều match (chữ, số, `_`)
- ` ` (space) → KHÔNG match
- `@` → KHÔNG match
- `admin` → 5 ký tự đều match
- ` ` (space) → KHÔNG match
- `hello` → match
- `-` → KHÔNG match (dấu gạch ngang không phải `_`)
- `world` → match

### 2.6. Dấu `\W` - KHÔNG phải ký tự từ

**`\W` = "1 ký tự KHÔNG phải chữ/số/underscore"**

```regex
\W
```
- Match: khoảng trắng, dấu câu, ký tự đặc biệt (`@`, `#`, `-`, `.`, `,`...)
- Không match: chữ, số, `_`

**Ví dụ:**
```
Text: "hello-world, test@123"
Regex: "\W"
Match: "hello-world, test@123"
             ^     ^     ^
```

### 2.7. Dấu `\s` - Khoảng trắng (Whitespace)

**`\s` = "1 khoảng trắng"**

Bao gồm:
- Space (dấu cách)
- Tab (`\t`)
- Newline (xuống dòng `\n`)

**Ví dụ:**
```
Text: "hello world"
Regex: "\s"
Match: "hello world"
             ^
```

### 2.8. Dấu `\S` - KHÔNG phải khoảng trắng

**`\S` = "1 ký tự KHÔNG phải khoảng trắng"**

```regex
\S
```
- Match: chữ, số, ký tự đặc biệt (mọi thứ trừ space/tab/newline)

**Ví dụ:**
```
Text: "hello world"
Regex: "\S"
Match: "hello world"
        ^^^^^ ^^^^^
```

### 2.9. Bảng tổng hợp ký tự cơ bản

| Ký tự | Ý nghĩa | Match | Không match |
|-------|---------|-------|-------------|
| `.` | Bất kỳ 1 ký tự | `a`, `9`, `@`, ` ` | (Không có) |
| `\d` | 1 chữ số | `0-9` | Chữ cái, ký tự đặc biệt |
| `\D` | KHÔNG phải chữ số | Chữ, ký tự đặc biệt | `0-9` |
| `\w` | Chữ/số/underscore | `a-z`, `A-Z`, `0-9`, `_` | Space, dấu câu |
| `\W` | KHÔNG phải word char | Space, `@`, `#`, `-` | Chữ, số, `_` |
| `\s` | Khoảng trắng | Space, Tab, Newline | Chữ, số |
| `\S` | KHÔNG phải space | Chữ, số, ký tự đặc biệt | Space, Tab |

**Mẹo ghi nhớ:**
- Chữ thường (`\d`, `\w`, `\s`) = match kiểu đó
- Chữ HOA (`\D`, `\W`, `\S`) = KHÔNG match kiểu đó

---

## 🔢 PHẦN 3: SỐ LƯỢNG (Quantifiers)

### 3.1. Tại sao cần số lượng?

Ví dụ: Tìm số điện thoại 10 chữ số
```
❌ Cách sai: "\d" → chỉ tìm 1 chữ số
✅ Cách đúng: "\d\d\d\d\d\d\d\d\d\d" → tìm 10 chữ số
```

Nhưng viết `\d` 10 lần rất dài → dùng **quantifier** (số lượng)!

### 3.2. Dấu `+` - Một hoặc nhiều

**`+` = "1 hoặc nhiều lần"**

```regex
\d+
```
- `\d` = 1 chữ số
- `+` = lặp lại 1 hoặc nhiều lần
- → Match: 1 chữ số, 2 chữ số, 3 chữ số, 100 chữ số...

**Ví dụ:**
```
Text: "Tôi có 5 táo và 123 cam"
Regex: "\d+"
Match: "Tôi có 5 táo và 123 cam"
             ^         ^^^
```

**Giải thích:**
- `5` → 1 chữ số → match
- `123` → 3 chữ số liên tiếp → match thành 1 nhóm

### 3.3. Dấu `*` - Không hoặc nhiều

**`*` = "0 hoặc nhiều lần"**

```regex
\d*
```
- Match: 0 chữ số (không có gì), 1 chữ số, 2 chữ số, nhiều chữ số...

**Ví dụ:**
```
Text: "abc123xyz"
Regex: "\d*"
Match: Khắp nơi (kể cả chỗ không có số)
```

**So sánh `+` và `*`:**
```
Text: "abc"
Regex: "\d+" → Không match (cần ít nhất 1 số, nhưng không có số)
Regex: "\d*" → Match rỗng ở mọi vị trí (0 số cũng được)
```

**Khi nào dùng `*`?**
- Khi thứ bạn tìm có thể **có hoặc không**
- Ví dụ: `http` hoặc `https` → `https?` (s có thể có hoặc không)

### 3.4. Dấu `?` - Không hoặc một

**`?` = "0 hoặc 1 lần"**

```regex
https?
```
- `http` → chữ http cố định
- `s?` → chữ s xuất hiện 0 hoặc 1 lần

**Ví dụ:**
```
Text: "Visit http://example.com or https://secure.com"
Regex: "https?"
Match: "Visit http://example.com or https://secure.com"
              ^^^^                    ^^^^^
```

**Giải thích:**
- `http` → match (s xuất hiện 0 lần)
- `https` → match (s xuất hiện 1 lần)
- `httpss` → KHÔNG match (s xuất hiện 2 lần, quá 1)

### 3.5. Dấu `{n}` - Chính xác n lần

**`{n}` = "Chính xác n lần"**

```regex
\d{10}
```
- Match: CHÍNH XÁC 10 chữ số liên tiếp
- Không match: 9 số, 11 số

**Ví dụ:**
```
Text: "SĐT: 0123456789 và 98765"
Regex: "\d{10}"
Match: "SĐT: 0123456789 và 98765"
             ^^^^^^^^^^
```

**Giải thích:**
- `0123456789` → 10 số → match ✅
- `98765` → 5 số → không match ❌

### 3.6. Dấu `{n,m}` - Từ n đến m lần

**`{n,m}` = "Từ n đến m lần"**

```regex
\d{3,5}
```
- Match: 3 số, 4 số, hoặc 5 số liên tiếp
- Không match: 2 số, 6 số

**Ví dụ:**
```
Text: "12 và 123 và 12345 và 123456"
Regex: "\d{3,5}"
Match: "12 và 123 và 12345 và 123456"
              ^^^     ^^^^^     ^^^^^
```

**Giải thích:**
- `12` → 2 số → không match ❌
- `123` → 3 số → match ✅
- `12345` → 5 số → match ✅
- `123456` → 6 số → match 5 số đầu tiên `12345`, số `6` thừa

### 3.7. Dấu `{n,}` - Ít nhất n lần

**`{n,}` = "Ít nhất n lần, không giới hạn trên"**

```regex
\d{3,}
```
- Match: 3 số, 4 số, 5 số, 100 số...
- Không match: 1 số, 2 số

**Ví dụ:**
```
Text: "12 và 123 và 123456789"
Regex: "\d{3,}"
Match: "12 và 123 và 123456789"
              ^^^     ^^^^^^^^^
```

### 3.8. Bảng tổng hợp Quantifiers

| Ký hiệu | Ý nghĩa | Ví dụ | Match |
|---------|---------|-------|-------|
| `+` | 1 hoặc nhiều | `\d+` | `1`, `123`, `99999` |
| `*` | 0 hoặc nhiều | `\d*` | (rỗng), `1`, `123` |
| `?` | 0 hoặc 1 | `s?` | (rỗng), `s` |
| `{3}` | Chính xác 3 | `\d{3}` | `123` |
| `{3,5}` | Từ 3 đến 5 | `\d{3,5}` | `123`, `1234`, `12345` |
| `{3,}` | Ít nhất 3 | `\d{3,}` | `123`, `12345`, `999999` |

**Ví dụ kết hợp:**
```regex
\w{5,10}
```
- Match: Từ 5-10 ký tự chữ/số/underscore
- Ví dụ: `hello`, `user_123`, `admin_user`

---

## 📦 PHẦN 4: TẬP HỢP (Character Classes)

### 4.1. Dấu ngoặc vuông `[]` - Tập hợp ký tự

**`[abc]` = "Một trong các ký tự a, b, hoặc c"**

```regex
[aeiou]
```
- Match: 1 nguyên âm bất kỳ (`a`, `e`, `i`, `o`, `u`)

**Ví dụ:**
```
Text: "cat, bet, sit, dog, run"
Regex: "[aeiou]"
Match: "cat, bet, sit, dog, run"
        ^ ^   ^ ^  ^ ^   ^ ^  ^ ^
```

### 4.2. Dải ký tự `-` (Range)

**`[a-z]` = "Một chữ cái từ a đến z"**

```regex
[a-z]
```
- Match: 1 chữ thường từ a-z

```regex
[A-Z]
```
- Match: 1 chữ HOA từ A-Z

```regex
[0-9]
```
- Match: 1 chữ số từ 0-9 (giống `\d`)

**Ví dụ:**
```
Text: "Hello123World"
Regex: "[a-z]"
Match: "Hello123World"
         ^^^    ^^^^ (chỉ match chữ thường)
```

### 4.3. Kết hợp nhiều dải

**`[a-zA-Z]` = "Chữ cái bất kỳ (hoa hoặc thường)"**

```regex
[a-zA-Z0-9]
```
- Match: chữ cái (hoa/thường) hoặc số

**Ví dụ:**
```
Text: "User123@Admin"
Regex: "[a-zA-Z0-9]"
Match: "User123@Admin"
        ^^^^^^^  ^^^^^
```

### 4.4. Dấu `^` trong `[]` - Phủ định

**`[^abc]` = "KHÔNG phải a, b, hoặc c"**

```regex
[^0-9]
```
- Match: Bất kỳ ký tự KHÔNG phải số
- Giống `\D`

**Ví dụ:**
```
Text: "abc123xyz"
Regex: "[^0-9]"
Match: "abc123xyz"
        ^^^   ^^^
```

**Lưu ý:**
- `^` ở **ĐẦU** trong `[]` = phủ định
- `^` ở **NGOÀI** `[]` = bắt đầu dòng (sẽ học sau)

### 4.5. Ký tự đặc biệt trong `[]`

Trong `[]`, hầu hết ký tự đặc biệt **mất ý nghĩa đặc biệt**:

```regex
[.]
```
- Match: Dấu chấm literal `.`
- KHÔNG có nghĩa "ký tự bất kỳ"

```regex
[+*?]
```
- Match: Dấu `+`, `*`, hoặc `?` literal
- KHÔNG có nghĩa "quantifier"

**Ngoại lệ cần escape:**
- `]` → phải viết `\]` (đóng ngoặc)
- `\` → phải viết `\\` (backslash)
- `^` ở đầu → phải viết `\^` (nếu muốn match ký tự `^`)

---

## 🎯 PHẦN 5: ANCHORS (Điểm neo)

### 5.1. Dấu `^` - Bắt đầu dòng

**`^` = "Bắt đầu của dòng/string"**

```regex
^Hello
```
- Match: Chữ "Hello" **ở đầu dòng**
- Không match: "Hello" ở giữa/cuối dòng

**Ví dụ:**
```
Text: "Hello world
      Say Hello"
Regex: "^Hello"
Match: Chỉ dòng 1 → "Hello world"
                     ^^^^^
```

### 5.2. Dấu `$` - Kết thúc dòng

**`$` = "Kết thúc của dòng/string"**

```regex
world$
```
- Match: Chữ "world" **ở cuối dòng**

**Ví dụ:**
```
Text: "Hello world
      world peace"
Regex: "world$"
Match: Chỉ dòng 1 → "Hello world"
                           ^^^^^
```

### 5.3. Kết hợp `^` và `$`

**`^...$` = "Toàn bộ dòng phải khớp pattern"**

```regex
^\d{10}$
```
- Dòng **chỉ chứa** 10 chữ số, không thừa, không thiếu

**Ví dụ:**
```
Text: "0123456789"   ✅ Match
Text: "012345678"    ❌ Không match (9 số)
Text: "01234567890"  ❌ Không match (11 số)
Text: "abc0123456789" ❌ Không match (có chữ)
```

### 5.4. Dấu `\b` - Word boundary

**`\b` = "Ranh giới từ"**

Ranh giới từ = chỗ chuyển từ `\w` sang `\W` (hoặc ngược lại)

```regex
\bhello\b
```
- Match: Từ "hello" **độc lập**
- Không match: "hello" trong "xinhello" hay "helloxin"

**Ví dụ:**
```
Text: "hello, xinhello, helloworld"
Regex: "\bhello\b"
Match: "hello, xinhello, helloworld"
        ^^^^^
```

**Giải thích:**
- `hello` đầu tiên: có ranh giới trước (đầu string) và sau (dấu phẩy) → match ✅
- `xinhello`: không có ranh giới trước (chữ `x` dính liền) → không match ❌
- `helloworld`: không có ranh giới sau (chữ `w` dính liền) → không match ❌

### 5.5. Dấu `\B` - KHÔNG phải word boundary

**`\B` = "KHÔNG phải ranh giới từ"**

```regex
\Bhello\B
```
- Match: "hello" **bị bao quanh** bởi ký tự chữ/số

**Ví dụ:**
```
Text: "xinhelloworld"
Regex: "\Bhello\B"
Match: "xinhelloworld"
           ^^^^^
```

---

## 🔀 PHẦN 6: NHÓM VÀ HOẶC

### 6.1. Dấu `|` - Hoặc (OR)

**`a|b` = "a HOẶC b"**

```regex
cat|dog
```
- Match: "cat" hoặc "dog"

**Ví dụ:**
```
Text: "I have a cat and a dog"
Regex: "cat|dog"
Match: "I have a cat and a dog"
                ^^^       ^^^
```

### 6.2. Dấu ngoặc tròn `()` - Nhóm

**`(abc)` = "Nhóm abc lại thành 1 đơn vị"**

```regex
(cat|dog)s
```
- Match: "cats" hoặc "dogs"

**Ví dụ:**
```
Text: "I love cats and dogs"
Regex: "(cat|dog)s"
Match: "I love cats and dogs"
               ^^^^     ^^^^
```

**Tại sao cần `()`?**

```regex
# Không có ():
cat|dogs  → Match: "cat" HOẶC "dogs"

# Có ():
(cat|dog)s → Match: "cats" HOẶC "dogs"
```

### 6.3. Capturing groups (Nhóm bắt)

**`()` còn dùng để "bắt" (capture) phần text**

```regex
(\d{2})/(\d{2})/(\d{4})
```
- Match date: `08/01/2026`
- Group 1: `08` (ngày)
- Group 2: `01` (tháng)
- Group 3: `2026` (năm)

**Dùng để làm gì?**
- Replace: Đổi `08/01/2026` → `2026-01-08`
- Extract: Lấy riêng ngày, tháng, năm

---

## 🛡️ PHẦN 7: ESCAPE (Ký tự thoát)

### 7.1. Tại sao cần escape?

Một số ký tự có **ý nghĩa đặc biệt** trong regex:
```
. ^ $ * + ? [ ] { } ( ) | \
```

Nếu muốn tìm **chính ký tự đó** (literal) → phải thêm `\` phía trước

### 7.2. Escape các ký tự đặc biệt

#### Ví dụ 1: Tìm dấu chấm
```regex
.  → Match mọi ký tự
\. → Match dấu chấm literal "."
```

**Ví dụ:**
```
Text: "File: test.txt"
Regex: "."  → Match tất cả ký tự
Regex: "\." → Match: "test.txt"
                           ^
```

#### Ví dụ 2: Tìm dấu `+`
```regex
+  → Quantifier (1 hoặc nhiều)
\+ → Match dấu + literal
```

**Ví dụ:**
```
Text: "5+3=8"
Regex: "+"  → Lỗi cú pháp!
Regex: "\+" → Match: "5+3=8"
                       ^
```

#### Ví dụ 3: Tìm backslash `\`
```regex
\  → Bắt đầu escape sequence
\\ → Match backslash literal "\"
```

**Ví dụ:**
```
Text: "Path: C:\Users\Admin"
Regex: "\\" → Match: "C:\Users\Admin"
                        ^     ^
```

### 7.3. Bảng ký tự cần escape

| Ký tự | Ý nghĩa đặc biệt | Escape | Ý nghĩa literal |
|-------|------------------|--------|-----------------|
| `.` | Ký tự bất kỳ | `\.` | Dấu chấm |
| `^` | Bắt đầu dòng | `\^` | Dấu mũ |
| `$` | Kết thúc dòng | `\$` | Dấu dollar |
| `*` | 0 hoặc nhiều | `\*` | Dấu sao |
| `+` | 1 hoặc nhiều | `\+` | Dấu cộng |
| `?` | 0 hoặc 1 | `\?` | Dấu hỏi |
| `[` | Bắt đầu tập hợp | `\[` | Ngoặc vuông mở |
| `]` | Kết thúc tập hợp | `\]` | Ngoặc vuông đóng |
| `{` | Bắt đầu quantifier | `\{` | Ngoặc nhọn mở |
| `}` | Kết thúc quantifier | `\}` | Ngoặc nhọn đóng |
| `(` | Bắt đầu nhóm | `\(` | Ngoặc tròn mở |
| `)` | Kết thúc nhóm | `\)` | Ngoặc tròn đóng |
| `|` | Hoặc (OR) | `\|` | Dấu gạch đứng |
| `\` | Escape | `\\` | Backslash |

### 7.4. Ví dụ thực tế: Tìm email

```regex
[\w.+-]+@[\w.-]+\.\w+
```

**Giải thích từng phần:**
1. `[\w.+-]+` → Username: chữ/số/underscore/dấu chấm/dấu cộng/dấu trừ
2. `@` → Dấu @ (không cần escape)
3. `[\w.-]+` → Domain: chữ/số/underscore/dấu chấm/dấu trừ
4. `\.` → Dấu chấm literal (escape!)
5. `\w+` → Extension: chữ/số/underscore

**Match:**
```
abc@gmail.com ✅
test_123@company.co.uk ✅
user+tag@email-server.vn ✅
```

---

## 📚 PHẦN 8: TỔNG KẾT VÀ GHI NHỚ

### 8.1. Bảng tổng hợp toàn bộ

| Loại | Ký tự | Ý nghĩa | Ví dụ |
|------|-------|---------|-------|
| **Cơ bản** | `.` | Ký tự bất kỳ | `h.t` → hat, hot |
| | `\d` | Chữ số 0-9 | `\d+` → 123 |
| | `\w` | Chữ/số/_ | `\w+` → hello_123 |
| | `\s` | Khoảng trắng | `\s` → space |
| **Số lượng** | `+` | 1 hoặc nhiều | `\d+` → 123 |
| | `*` | 0 hoặc nhiều | `\d*` → (rỗng)/123 |
| | `?` | 0 hoặc 1 | `s?` → s hoặc rỗng |
| | `{n}` | Chính xác n | `\d{3}` → 123 |
| | `{n,m}` | Từ n đến m | `\d{3,5}` → 123-12345 |
| **Tập hợp** | `[abc]` | a hoặc b hoặc c | `[aeiou]` → nguyên âm |
| | `[a-z]` | Từ a đến z | `[a-z]` → chữ thường |
| | `[^abc]` | KHÔNG phải a/b/c | `[^0-9]` → không phải số |
| **Anchors** | `^` | Bắt đầu dòng | `^Hello` |
| | `$` | Kết thúc dòng | `world$` |
| | `\b` | Ranh giới từ | `\bhello\b` |
| **Nhóm** | `|` | Hoặc | `cat|dog` |
| | `()` | Nhóm | `(cat|dog)s` |

### 8.2. Quy trình viết regex từng bước

**Bước 1: Xác định bài toán**
- Bạn cần tìm gì? (số điện thoại, email, date...)

**Bước 2: Phân tích cấu trúc**
- Ví dụ email: `abc@gmail.com`
- Phần 1: username (`abc`)
- Phần 2: `@`
- Phần 3: domain (`gmail`)
- Phần 4: `.`
- Phần 5: extension (`com`)

**Bước 3: Viết pattern từng phần**
- Username: `\w+` (chữ/số/underscore)
- @: `@`
- Domain: `\w+`
- Dot: `\.` (escape!)
- Extension: `\w+`

**Bước 4: Ghép lại**
```regex
\w+@\w+\.\w+
```

**Bước 5: Test và refine**
- Test trên regex101.com
- Thêm ký tự nếu thiếu: `[\w.+-]+@[\w.-]+\.\w+`
- Test lại

### 8.3. Mẹo ghi nhớ

#### 1. Chữ thường vs chữ HOA
```
\d = digit (số)
\D = KHÔNG phải digit

\w = word character (chữ/số/_)
\W = KHÔNG phải word character

\s = space (khoảng trắng)
\S = KHÔNG phải space
```

#### 2. Quantifiers theo mức độ "tham lam"
```
?  → Ít nhất (0 hoặc 1)
+  → Vừa phải (1 hoặc nhiều)
*  → Tham lam nhất (0 hoặc nhiều)
```

#### 3. Anchors
```
^  → Bắt đầu (^ giống mũi tên chỉ lên)
$  → Kết thúc ($ là "hết tiền" = kết thúc)
\b → Boundary (ranh giới)
```

#### 4. Escape rule
```
Nếu ký tự có ý nghĩa đặc biệt → thêm \ phía trước
Ví dụ: . ^ $ * + ? [ ] { } ( ) | \
```

---

## ✅ CHECKLIST TỰ KIỂM TRA

Trả lời các câu hỏi sau để kiểm tra bạn đã hiểu chưa:

### Phần 1: Ký tự cơ bản
- [ ] `\d` match gì? (Chữ số 0-9)
- [ ] `\w` match gì? (Chữ/số/_)
- [ ] `.` match gì? (Bất kỳ 1 ký tự)
- [ ] `\s` match gì? (Khoảng trắng)

### Phần 2: Quantifiers
- [ ] `\d+` match gì? (1 hoặc nhiều chữ số)
- [ ] `\d*` match gì? (0 hoặc nhiều chữ số)
- [ ] `\d?` match gì? (0 hoặc 1 chữ số)
- [ ] `\d{3}` match gì? (Chính xác 3 chữ số)

### Phần 3: Tập hợp
- [ ] `[abc]` match gì? (a hoặc b hoặc c)
- [ ] `[0-9]` match gì? (Chữ số, giống \d)
- [ ] `[^0-9]` match gì? (KHÔNG phải số)

### Phần 4: Anchors
- [ ] `^Hello` match gì? (Hello ở đầu dòng)
- [ ] `world$` match gì? (world ở cuối dòng)
- [ ] `\bcat\b` match gì? (Từ "cat" độc lập)

### Phần 5: Escape
- [ ] Làm sao match dấu chấm? (`\.`)
- [ ] Làm sao match dấu cộng? (`\+`)
- [ ] Làm sao match backslash? (`\\`)

**Nếu trả lời đúng 12/15 câu → Bạn đã sẵn sàng practice!** 🎉

---

## 🚀 NEXT STEPS

Sau khi hiểu lý thuyết này:

1. **Mở regex101.com** và test từng pattern trong bài
2. **Đọc file task1-practice.md** để làm bài tập
3. **Practice hàng ngày** với data thực tế của bạn

**Remember:** Regex là kỹ năng thực hành, không phải học thuộc lòng! 💪
