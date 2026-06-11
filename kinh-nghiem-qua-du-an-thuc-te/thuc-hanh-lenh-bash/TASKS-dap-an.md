# Đáp án — Linux vs PowerShell

> Mỗi task: lệnh Linux → lệnh PowerShell → Why (tại sao dùng flag/syntax đó) → How (cơ chế hoạt động).
> Root làm việc: `thuc-hanh-lenh/` (coi như `/` trên server).

progress: xong sprint 1
---

## 🔴 Sprint 1 — Search & Find

---

### Task 1 — Xóa hết `.tmp` trong `/var/tmp`

```bash
# Linux
find var/tmp -name "*.tmp" -delete
```
```powershell
# PowerShell
Get-ChildItem -Path var\tmp -Recurse -Filter "*.tmp" | Remove-Item
```

**Why:** `find` với `-delete` là atomic — nó xóa ngay tại chỗ thay vì pipe sang `rm`, tránh race condition nếu file đang được tạo mới. PowerShell dùng pipe vì không có flag `-delete` built-in.

**How:** `find` duyệt cây thư mục depth-first, mỗi file match pattern thì gọi `unlink()` syscall luôn. PowerShell `Get-ChildItem -Recurse` trả về object FileInfo, pipe sang `Remove-Item` gọi `.Delete()` từng cái.

---

### Task 2 — Liệt kê tất cả `.log` trong `/var/log`

```bash
# Linux
find var/log -name "*.log"
```
```powershell
# PowerShell
Get-ChildItem -Path var\log -Recurse -Filter "*.log"
```

**Why:** `-name` dùng glob pattern (không phải regex). `-Recurse` trong PowerShell mới đi vào subfolder — thiếu flag này chỉ tìm level 1.

**How:** `find` walk toàn bộ inode trong subtree. `Get-ChildItem -Filter` hiệu quả hơn `| Where-Object Name -like` vì filter được áp dụng ở tầng filesystem driver, không load hết object lên memory rồi mới lọc.

---

### Task 3 — Tìm file nặng hơn 50KB trong `/home/deploy/uploads`

```bash
# Linux
find home/deploy/uploads -size +50k
```
```powershell
# PowerShell
Get-ChildItem -Path home\deploy\uploads -Recurse | Where-Object { $_.Length -gt 50KB }
```

**Why:** `+50k` trong `find` = strictly greater than 50 kilobytes (đơn vị 512-byte block, `k` = 1024 bytes). PowerShell dùng `50KB` là literal constant = 51200 bytes.

**How:** `find -size` so sánh với st_size trong inode metadata — không cần đọc nội dung file. PowerShell `.Length` là property của FileInfo object, cũng từ metadata, không đọc file.

---

### Task 4 — Tìm file bị sửa trong 24h gần đây

```bash
# Linux
find srv/digidinos-app -mtime -1
```
```powershell
# PowerShell
Get-ChildItem -Path srv\digidinos-app -Recurse | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }
```

**Why:** `-mtime -1` = modified time < 1 ngày trước (tức là trong vòng 24h). Dấu `-` là "less than", `+` là "more than", không có dấu là "exactly". Nhiều người hay nhầm `0` và `1` ở đây.

**How:** `find` đọc `st_mtime` từ inode. PowerShell `LastWriteTime` cũng là mtime, nhưng được wrap thành DateTime object nên có thể dùng toán tử so sánh trực tiếp — dễ đọc hơn nhưng chậm hơn vì phải tạo DateTime object cho từng file.

---

### Task 5 — Tìm `.sh` và cấp quyền execute

```bash
# Linux
find srv/digidinos-app/scripts -name "*.sh" -exec chmod +x {} \;
```
```powershell
# PowerShell
# Windows không có chmod — thực tế dùng icacls hoặc bỏ qua
# Tương đương với .ps1:
Get-ChildItem -Path srv\digidinos-app\scripts -Recurse -Filter "*.ps1" | ForEach-Object {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
}
```

**Why:** `-exec {} \;` chạy lệnh một lần cho mỗi file (dấu `\;` kết thúc exec). Dùng `+` thay `\;` nếu muốn batch — `chmod +x file1 file2 file3` — nhanh hơn vì ít fork process hơn: `-exec chmod +x {} +`.

**How:** Với `\;`, `find` fork một process `chmod` cho mỗi file. Với `+`, `find` gom nhiều file thành 1 lần gọi. Trên 1000 file, `+` nhanh hơn đáng kể.

---

### Task 6 — Tìm process `node` đang chạy

```bash
# Linux
ps aux | grep node
```
```powershell
# PowerShell
Get-Process | Where-Object { $_.Name -like "*node*" }
```

**Why:** `ps aux` list tất cả process của mọi user (`a`) với format user-oriented (`u`) và process không attach terminal (`x`). Grep sau đó để lọc. PowerShell `Get-Process` trả về object — filter bằng `Where-Object` thay vì text grep.

**How:** `ps` đọc từ `/proc/` filesystem. `grep node` so sánh text line. Vấn đề: kết quả sẽ có thêm dòng `grep node` chính nó — fix bằng `grep [n]ode` (regex trick) hoặc `pgrep node`. PowerShell không bị vấn đề này vì filter trên object trước khi hiển thị.

---

### Task 7 — Grep ERROR kèm line number

```bash
# Linux
grep -n "ERROR" var/log/app/2026/06/01/app.log
```
```powershell
# PowerShell
Select-String -Pattern "ERROR" -Path var\log\app\2026\06\01\app.log
```

**Why:** `-n` trong grep bắt buộc phải viết tường minh để hiện line number. `Select-String` luôn hiển thị line number mặc định — không cần flag thêm.

**How:** `grep` scan từng byte, tìm newline để đếm dòng, in `linenum:content` khi match. `Select-String` trả về `MatchInfo` object với property `LineNumber`, `Line`, `Path` — có thể dùng tiếp trong pipeline mà không mất thông tin.

---

### Task 8 — Tìm file chứa chữ "staging"

```bash
# Linux
grep -rl "staging" srv/digidinos-app
```
```powershell
# PowerShell
Get-ChildItem -Path srv\digidinos-app -Recurse | Select-String "staging" | Select-Object -ExpandProperty Path -Unique
```

**Why:** `-r` = recursive, `-l` = chỉ in tên file (không in nội dung match). Rất hữu dụng khi chỉ cần biết "file nào bị ảnh hưởng". PowerShell cần thêm `Select-Object -Unique` vì nếu file có 3 dòng match thì `Select-String` trả về 3 object cùng Path.

**How:** `grep -rl` dừng scan file ngay khi tìm thấy match đầu tiên (vì `-l` chỉ cần biết có hay không). `grep -r` (không có `-l`) scan hết file. Nên dùng `-l` khi chỉ cần tên file — nhanh hơn nhiều với file lớn.

---

### Task 9 — Tìm IP bắn 401

```bash
# Linux
grep " 401 " var/log/nginx/access.log
```
```powershell
# PowerShell
Select-String -Pattern " 401 " -Path var\log\nginx\access.log
```

**Why:** Thêm khoảng trắng quanh `401` để tránh match nhầm URL có `401` trong path (ví dụ `/product/4018`). Pattern cụ thể hơn = ít false positive hơn.

**How:** Cả hai dùng regex engine. `" 401 "` là literal string (không có regex special char), nên match nhanh — không cần compile regex tree phức tạp.

---

### Task 10 — Tìm vị trí executable

```bash
# Linux
which node
```
```powershell
# PowerShell
Get-Command node
# hoặc xem chỉ path:
(Get-Command node).Source
```

**Why:** `which` chỉ tìm trong `$PATH`. `Get-Command` tìm cả alias, function, cmdlet, và external executable — kết quả đầy đủ hơn. Dùng `.Source` để lấy đúng file path.

**How:** `which` scan từng directory trong `$PATH` theo thứ tự, dừng khi tìm thấy file executable đầu tiên. `Get-Command` dùng cùng cơ chế nhưng cũng search `$env:PATH` và CommandInfo registry nội bộ của PowerShell.

---

## 🟡 Sprint 2 — Text Processing

---

### Task 11 — Đếm dòng ERROR

```bash
# Linux
grep -c "ERROR" var/log/app/2026/06/01/app.log
# hoặc:
grep "ERROR" var/log/app/2026/06/01/app.log | wc -l
```
```powershell
# PowerShell
(Select-String -Pattern "ERROR" -Path var\log\app\2026\06\01\app.log).Count
```

**Why:** `grep -c` hiệu quả hơn `grep | wc -l` vì không cần pipe — grep đếm nội bộ. PowerShell dùng `.Count` trên array kết quả.

**How:** `grep -c` đếm số dòng match, không in nội dung — tiết kiệm buffer. `wc -l` đếm newline character trong stdin. Hai cách cho kết quả giống nhau nhưng `grep -c` ít overhead hơn.

---

### Task 12 — Lấy cột `name` và `email` từ CSV

```bash
# Linux
cut -d',' -f2,3 users.csv
```
```powershell
# PowerShell
Import-Csv users.csv | Select-Object name, email
```

**Why:** `cut -d',' -f2,3` cắt theo delimiter `,`, lấy field 2 và 3 (index từ 1). Vấn đề: `cut` không xử lý CSV có quoted field (ví dụ `"Nguyen, Van An"` sẽ bị cắt sai). `Import-Csv` parse đúng CSV spec kể cả quoted field.

**How:** `cut` là text processor thuần — split theo delimiter, lấy field theo index. `Import-Csv` dùng CSV parser thật, tạo object với property name từ header row — an toàn hơn khi data phức tạp.

---

### Task 13 — Sort nội dung file

```bash
# Linux
sort var/log/cron/cron.log
```
```powershell
# PowerShell
Get-Content var\log\cron\cron.log | Sort-Object
```

**Why:** `sort` mặc định là lexicographic (alphabetical). Nếu muốn sort số dùng `-n`, sort ngược dùng `-r`. PowerShell `Sort-Object` cũng lexicographic mặc định.

**How:** `sort` đọc toàn bộ input vào memory (hoặc temp file nếu lớn quá), rồi sắp xếp, rồi in. Với file lớn (GB+), `sort` có external merge sort. PowerShell load hết vào memory array rồi sort — không phù hợp file cực lớn.

---

### Task 14 — Lấy IP unique từ access.log

```bash
# Linux
# Bước 1: lấy cột IP (cột 1), bước 2: sort, bước 3: unique
awk '{print $1}' var/log/nginx/access.log | sort -u
```
```powershell
# PowerShell
Get-Content var\log\nginx\access.log |
    ForEach-Object { ($_ -split ' ')[0] } |
    Sort-Object -Unique
```

**Why:** Phải sort trước khi `uniq` vì `uniq` chỉ dedup dòng liền kề nhau — không sort trước thì `uniq` sẽ bỏ sót duplicate không liền kề. `sort -u` là shortcut của `sort | uniq`.

**How:** `awk '{print $1}'` split theo whitespace, lấy field 1. `sort` sắp xếp, `uniq` (hoặc `sort -u`) so sánh từng dòng với dòng trước — O(n log n) tổng thể. PowerShell `Sort-Object -Unique` làm cả hai bước trong một.

---

### Task 15 — Đếm tổng số dòng file

```bash
# Linux
wc -l var/log/app/2026/06/01/app.log
```
```powershell
# PowerShell
(Get-Content var\log\app\2026\06\01\app.log).Count
```

**Why:** `wc -l` đếm ký tự newline `\n` — nhanh vì không cần parse nội dung. Nếu dòng cuối không có newline, count sẽ thiếu 1. PowerShell `Get-Content` split thành array theo newline rồi `.Count` — chính xác hơn.

**How:** `wc -l` scan byte stream, đếm `0x0A`. PowerShell đọc toàn bộ file vào memory, split theo `\r\n` hoặc `\n`, trả về `String[]` — tốn memory hơn nhưng handle edge case cuối file tốt hơn.

---

### Task 16 — Replace "staging" → "production" in-place

```bash
# Linux
sed -i 's/staging/production/g' srv/digidinos-app/backend/config/staging.env
```
```powershell
# PowerShell
(Get-Content srv\digidinos-app\backend\config\staging.env) -replace 'staging','production' |
    Set-Content srv\digidinos-app\backend\config\staging.env
```

**Why:** `s/old/new/g` — `s` là substitute, `g` là global (replace tất cả match trong dòng, không phải chỉ match đầu tiên). Thiếu `g` thì chỉ replace lần đầu mỗi dòng. `-i` = in-place (sửa file thật, không in ra stdout).

**How:** `sed -i` thực ra tạo file temp, ghi nội dung mới vào đó, rồi rename thay thế file gốc — không sửa byte trực tiếp trong file. PowerShell làm tương tự: đọc hết vào memory, apply replace, ghi lại bằng `Set-Content`. Cả hai đều nguy hiểm nếu process bị kill giữa chừng — nên backup trước.

---

### Task 17 — Lấy cột cpu_usage (cột 2)

```bash
# Linux
awk '{print $2}' opt/backups/daily/report_20260601.txt
# Bỏ dòng header:
awk 'NR>1 {print $2}' opt/backups/daily/report_20260601.txt
```
```powershell
# PowerShell
Get-Content opt\backups\daily\report_20260601.txt |
    Select-Object -Skip 1 |
    ForEach-Object { ($_ -split '\s+')[1] }
```

**Why:** `awk` split theo whitespace mặc định (không cần chỉ định delimiter). `NR>1` = skip dòng header (NR = Number of Record = số thứ tự dòng hiện tại). PowerShell dùng `-Skip 1` để bỏ header.

**How:** `awk` xử lý từng dòng, `$2` là field thứ 2 sau khi split. PowerShell `-split '\s+'` split theo một hoặc nhiều whitespace liên tiếp — quan trọng với file có indent tab/space không đều.

---

### Task 18 — Append dòng vào file

```bash
# Linux
echo "Note: Brute force blocked at 11:00" >> opt/backups/daily/report_20260601.txt
```
```powershell
# PowerShell
"Note: Brute force blocked at 11:00" | Add-Content opt\backups\daily\report_20260601.txt
```

**Why:** `>>` là append redirect — khác với `>` là overwrite. Nhầm `>` và `>>` là lỗi kinh điển gây mất dữ liệu. `Add-Content` luôn append, không có rủi ro overwrite.

**How:** `>>` mở file với flag `O_APPEND` — kernel đảm bảo write luôn vào cuối file, kể cả có concurrent writer khác. `Add-Content` dùng `FileMode.Append` trong .NET — tương đương.

---

### Task 19 — Lấy 10 dòng đầu

```bash
# Linux
head -10 var/log/app/2026/06/01/app.log
```
```powershell
# PowerShell
Get-Content var\log\app\2026\06\01\app.log | Select-Object -First 10
```

**Why:** `head` không cần đọc toàn bộ file — dừng sau khi đọc đủ N dòng. Rất nhanh với file log GB. PowerShell `Select-Object -First 10` cũng dừng pipeline sớm — không đọc hết file vào memory.

**How:** `head` dùng `read()` syscall và dừng sau khi đếm đủ newline. PowerShell pipeline lazy evaluation — `Get-Content` chỉ stream từng dòng, `Select-Object -First 10` stop pipeline sau dòng thứ 10, `Get-Content` không đọc thêm.

---

### Task 20 — Lấy 5 dòng cuối

```bash
# Linux
tail -5 var/log/app/2026/06/02/app.log
```
```powershell
# PowerShell
Get-Content var\log\app\2026\06\02\app.log | Select-Object -Last 5
```

**Why:** `tail` cần đọc đến cuối file để biết đâu là N dòng cuối — không lazy như `head`. Với file log lớn, `tail` dùng trick seek đến gần cuối file thay vì đọc từ đầu.

**How:** `tail` seek đến cuối file (`lseek(fd, 0, SEEK_END)`), đọc ngược lại đếm newline, in phần cần thiết — O(file_size) worst case nhưng thường O(tail_size). PowerShell `Select-Object -Last` phải buffer toàn bộ stream — kém hơn `tail` với file lớn.

---

### Task 21 — Xóa dòng trống

```bash
# Linux
grep -v '^$' etc/nginx/conf.d/gzip.conf
# In-place:
grep -v '^$' etc/nginx/conf.d/gzip.conf | sponge etc/nginx/conf.d/gzip.conf
# Hoặc dùng sed:
sed -i '/^$/d' etc/nginx/conf.d/gzip.conf
```
```powershell
# PowerShell
(Get-Content etc\nginx\conf.d\gzip.conf) | Where-Object { $_ -ne '' } |
    Set-Content etc\nginx\conf.d\gzip.conf
```

**Why:** `^$` là regex: `^` = đầu dòng, `$` = cuối dòng — nếu đầu và cuối liền nhau tức là dòng rỗng. `-v` = invert (lấy những dòng KHÔNG match). `sponge` từ package `moreutils` — đọc hết stdin rồi mới ghi ra file, tránh race condition khi đọc và ghi cùng file.

**How:** Pipe `grep -v '^$' file > file` trực tiếp sẽ truncate file trước khi grep đọc xong — kết quả là file rỗng. Phải dùng `sponge` hoặc temp file. PowerShell tránh được vấn đề này vì `(Get-Content)` đọc hết vào memory trước rồi mới `Set-Content`.

---

### Task 22 — Lấy dòng WARN và ERROR (loại INFO)

```bash
# Linux
grep -v "INFO" var/log/app/2026/06/01/app.log
```
```powershell
# PowerShell
Get-Content var\log\app\2026\06\01\app.log | Where-Object { $_ -notmatch "INFO" }
```

**Why:** Dễ hơn là grep `ERROR|WARN` (phải nhớ hết level). Loại trừ `INFO` ra thì còn lại WARN, ERROR, và cả DEBUG nếu có. Tùy context nên chọn approach nào.

**How:** `-v` flip kết quả boolean của match. `-notmatch` trong PowerShell là negated regex match. Cả hai đều O(n) — scan từng dòng.

---

### Task 23 — Trim whitespace đầu/cuối

```bash
# Linux
sed 's/^[[:space:]]*//;s/[[:space:]]*$//' etc/nginx/conf.d/gzip.conf
```
```powershell
# PowerShell
(Get-Content etc\nginx\conf.d\gzip.conf) | ForEach-Object { $_.Trim() }
```

**Why:** `[[:space:]]` là POSIX character class — match space, tab, newline. Dùng `[[:space:]]` thay vì `[ \t]` vì portable hơn giữa các distro. `*` = zero or more. Hai lệnh `s///` cách nhau `;` để chạy tuần tự trong cùng sed invocation.

**How:** `sed` apply regex substitution từng dòng. PowerShell `.Trim()` là .NET String method — nhanh và đơn giản hơn, không cần viết regex.

---

### Task 24 — Tìm dòng chứa "Revenue"

```bash
# Linux
grep "Revenue" opt/backups/daily/report_20260601.txt
```
```powershell
# PowerShell
Select-String -Pattern "Revenue" -Path opt\backups\daily\report_20260601.txt
```

**Why:** Task đơn giản — grep/Select-String cơ bản. Điểm cần nhớ: mặc định là case-sensitive trong Linux grep, case-insensitive trong `Select-String`. Thêm `-i` (Linux) hoặc `-CaseSensitive` (PowerShell) để control.

**How:** Pattern `Revenue` là literal string — không có regex special char nên engine dùng Boyer-Moore hoặc Knuth-Morris-Pratt để search nhanh hơn brute force.

---

### Task 25 — Merge 2 file log

```bash
# Linux
cat var/log/app/2026/06/01/app.log var/log/app/2026/06/02/app.log > opt/backups/daily/app_june.log
```
```powershell
# PowerShell
Get-Content var\log\app\2026\06\01\app.log, var\log\app\2026\06\02\app.log |
    Set-Content opt\backups\daily\app_june.log
```

**Why:** `cat` với nhiều file đơn giản là concat — đọc lần lượt và stream ra stdout. Redirect `>` ghi vào file mới. Không sort hay dedup — thứ tự dòng giữ nguyên theo thứ tự file.

**How:** `cat` stream từng byte từ file 1 rồi file 2 vào stdout. Kernel buffer I/O — cực nhanh, không load hết vào memory. PowerShell `Get-Content f1, f2` nhận array path, stream từng file nối tiếp nhau qua pipeline.

---

## 🟢 Sprint 3 — Kết hợp

---

### Task 26 — Tìm file `.log` chứa "OutOfMemory"

```bash
# Linux
grep -rl "OutOfMemory" var/log
# Hoặc kết hợp find để chỉ search file .log:
find var/log -name "*.log" -exec grep -l "OutOfMemory" {} \;
```
```powershell
# PowerShell
Get-ChildItem -Path var\log -Recurse -Filter "*.log" |
    Select-String "OutOfMemory" |
    Select-Object -ExpandProperty Path -Unique
```

**Why:** `grep -rl` tìm nhanh hơn vì dừng scan file ngay khi tìm thấy match đầu tiên. Kết hợp `find + grep` hữu ích khi cần filter theo loại file trước (ví dụ chỉ `.log`, bỏ `.gz`).

**How:** Kết quả tìm được: `var/log/app/2026/06/01/app.log` (có dòng `OutOfMemoryError`). Đây là lỗi thật trong incident ngày 01/06.

---

### Task 27 — Đếm số lần mỗi service xuất hiện

```bash
# Linux
grep -o '\[.*Service\]' var/log/app/2026/06/01/app.log | sort | uniq -c | sort -rn
```
```powershell
# PowerShell
Select-String -Pattern '\[\w+Service\]' var\log\app\2026\06\01\app.log |
    ForEach-Object { $_.Matches[0].Value } |
    Group-Object |
    Sort-Object Count -Descending |
    Select-Object Count, Name
```

**Why:** `grep -o` chỉ in phần match (không in cả dòng) — chuẩn bị input cho `uniq -c`. `uniq -c` đếm số lần xuất hiện của mỗi dòng liền kề — phải sort trước. `sort -rn` = sort ngược (`r`) theo số (`n`) để thấy service nhiều nhất trước.

**How:** Pipeline: extract service name → sort → count → sort by count. PowerShell `Group-Object` làm bước sort+count trong một — trả về object `{Count, Name, Group}`.

**Kết quả mong đợi:**
```
7 [AuthService]
5 [PaymentService]
3 [CronJob]
2 [DatabaseService]
2 [EmailService]
...
```

---

### Task 28 — IP bị 401, sort, lưu file

```bash
# Linux
grep " 401 " var/log/nginx/access.log | awk '{print $1}' | sort -u > opt/backups/daily/suspicious_ips.txt
```
```powershell
# PowerShell
Select-String -Pattern " 401 " var\log\nginx\access.log |
    ForEach-Object { ($_.Line -split ' ')[0] } |
    Sort-Object -Unique |
    Set-Content opt\backups\daily\suspicious_ips.txt
```

**Why:** Pipeline 3 bước: lọc dòng 401 → lấy cột IP → dedup. `awk '{print $1}'` lấy cột đầu (IP) nhanh hơn `cut -d' ' -f1` khi whitespace không đều. Redirect `>` ghi file kết quả.

**How:** Kết quả từ data thật trong bài: IP `203.0.113.99` — đúng IP đang brute force. File output sẽ có 1 dòng: `203.0.113.99`.

---

### Task 29 — Tìm đường dẫn upload trong log

```bash
# Linux
grep "/home/deploy/uploads" var/log/app/2026/06/01/app.log
# Chỉ lấy phần path:
grep -o '/home/deploy/uploads/[^ ]*' var/log/app/2026/06/01/app.log
```
```powershell
# PowerShell
Select-String -Pattern "/home/deploy/uploads" var\log\app\2026\06\01\app.log |
    ForEach-Object { $_.Line }
```

**Why:** `grep -o` với pattern chứa `[^ ]*` (mọi ký tự không phải space) để extract đúng phần path, không lấy cả dòng log thừa. Hữu ích khi cần list path để audit.

**How:** Kết quả mong đợi từ `app.log`: `/home/deploy/uploads/2026/06/invoices/invoice_large.pdf` — đây là file 120MB user hoang.dv upload lúc 09:06.

---

### Task 30 — Chuyển đổi bash sang PowerShell

**Script gốc trong `cleanup.sh`:**
```bash
find $SESSIONS_DIR -name "*.tmp" -mtime +1 -delete
```

**Giải thích từng flag:**
- `$SESSIONS_DIR` = biến chứa path
- `-name "*.tmp"` = chỉ file `.tmp`
- `-mtime +1` = modified hơn 1 ngày trước (cũ hơn 24h)
- `-delete` = xóa luôn

**Tương đương PowerShell:**
```powershell
$sessionsDir = "var\tmp\sessions"

Get-ChildItem -Path $sessionsDir -Filter "*.tmp" |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) } |
    Remove-Item
```

**Why:** `-mtime +1` trong `find` = "older than 1 day" = LastWriteTime nhỏ hơn 24h trước. Dùng `-lt` (less than) chứ không phải `-gt` — hay nhầm ở điểm này.

**How:** `find -mtime +N` so sánh: `(now - mtime) / 86400 > N`. Tức là file phải cũ hơn N ngày tính theo block 24h. PowerShell `AddDays(-1)` trả về DateTime chính xác đến giây — chính xác hơn nhưng logic giống nhau.

**Gotcha:** `find -mtime +1` không phải "hơn 24h" mà là "hơn 1 ngày đầy đủ" theo block 24h của hệ thống. File tạo 25h trước với `-mtime +1` sẽ match, nhưng file tạo 23h trước thì không. PowerShell `AddDays(-1)` chính xác hơn — tính đúng 86400 giây.
