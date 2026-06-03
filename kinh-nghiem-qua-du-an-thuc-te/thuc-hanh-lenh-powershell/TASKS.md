# Tasks thực hành — Linux vs PowerShell

> Leader giao việc. Không nhìn cột "Lệnh liên quan" trước khi tự nghĩ.
> Root của server giả lập: `thuc-hanh-lenh/`

---

## Cấu trúc server

```
thuc-hanh-lenh/               ← coi như /  (root)
├── var/
│   ├── log/
│   │   ├── nginx/
│   │   │   ├── access.log
│   │   │   └── error.log
│   │   ├── app/
│   │   │   ├── 2026/06/01/app.log
│   │   │   ├── 2026/06/02/app.log
│   │   │   └── archived/app_20260501.log.gz
│   │   └── cron/cron.log
│   └── tmp/
│       ├── sessions/session_*.tmp
│       ├── cache/level1/level2/*.tmp
│       └── uploads/chunk_*.tmp
├── srv/
│   └── digidinos-app/
│       ├── backend/
│       │   ├── config/production.env  staging.env
│       │   └── src/
│       │       ├── services/   AuthService.js  PaymentService.js  ReportService.js
│       │       ├── controllers/OrderController.js
│       │       └── middlewares/rateLimit.js
│       ├── frontend/src/components/  public/
│       └── scripts/
│           ├── deploy/deploy_production.sh
│           ├── cron/cleanup.sh  backup.sh
│           └── maintenance/rotate_logs.sh
├── etc/
│   └── nginx/
│       ├── sites-available/digidinos.com.conf
│       └── conf.d/gzip.conf
├── home/
│   └── deploy/uploads/
│       ├── 2026/06/invoices/  avatars/
│       ├── 2026/05/invoices/
│       └── tmp/chunk_upload_pending.tmp
└── opt/
    └── backups/
        ├── daily/   report_20260601.txt  backup_20260601.tar.gz
        ├── weekly/  backup_week22_2026.tar.gz
        └── database/db_20260601.sql.gz
```

---

## 🔴 Sprint 1 — Search & Find

| # | Task từ leader | Lệnh liên quan |
|---|---------------|---------------|
| 1 | "Server sắp full disk, tìm và xóa hết file `.tmp` trong toàn bộ `/var/tmp` đi." | `find -name -delete` / `Get-ChildItem -Recurse -Filter \| Remove-Item` |
| 2 | "Liệt kê tất cả file `.log` trong `/var/log` kể cả thư mục con — cần biết có bao nhiêu file để lên kế hoạch rotate." | `find -name "*.log"` / `Get-ChildItem -Recurse -Filter "*.log"` |
| 3 | "Tìm file nào trong `/home/deploy/uploads` nặng hơn 50KB — cần check xem user upload gì bất thường không." | `find -size +50k` / `Where-Object { $_.Length -gt 50KB }` |
| 4 | "Hôm qua có incident lúc 11h, tìm xem file nào trong `/srv/digidinos-app` bị sửa trong 24h gần đây." | `find -mtime -1` / `Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }` |
| 5 | "Tìm tất cả file `.sh` trong `/srv/digidinos-app/scripts` — chuẩn bị cấp quyền execute trước khi deploy." | `find -name "*.sh" -exec chmod +x {} \;` / `Get-ChildItem -Recurse -Filter "*.ps1" \| ForEach-Object` |
| 6 | "Check xem có process nào liên quan đến `node` đang chạy không — nghi memory leak." | `ps aux \| grep node` / `Get-Process \| Where-Object { $_.Name -like "*node*" }` |
| 7 | "Grep trong `var/log/app/2026/06/01/app.log` xem `ERROR` xuất hiện ở dòng nào." | `grep -n "ERROR"` / `Select-String "ERROR"` (tự có line number) |
| 8 | "Tìm tất cả file trong `/srv/digidinos-app` có chứa chữ `staging` — phải đổi sang `production` trước 5h chiều." | `grep -rl "staging"` / `Get-ChildItem -Recurse \| Select-String "staging" \| Select Path -Unique` |
| 9 | "Trong `var/log/nginx/access.log`, IP nào đang bắn request 401 liên tục? Show ra để mình block." | `grep "401"` / `Select-String "401"` |
| 10 | "Tìm xem `node` executable nằm ở đâu trên hệ thống." | `which node` / `Get-Command node` |

---

## 🟡 Sprint 2 — Text Processing

| # | Task từ leader | Lệnh liên quan |
|---|---------------|---------------|
| 11 | "Đếm bao nhiêu dòng ERROR trong `var/log/app/2026/06/01/app.log` — PM hỏi số liệu incident." | `grep "ERROR" \| wc -l` / `Select-String "ERROR" \| Measure-Object` |
| 12 | "Lấy cột `name` và `email` từ file `users.csv` gửi cho HR (giả sử bạn tạo file này để luyện)." | `cut -d',' -f2,3` / `Import-Csv \| Select-Object name,email` |
| 13 | "Sort nội dung `var/log/cron/cron.log` theo thứ tự alphabet để dễ đọc." | `sort` / `Get-Content \| Sort-Object` |
| 14 | "Lấy danh sách IP unique từ `var/log/nginx/access.log` — cần biết có bao nhiêu client." | `sort -u` / `Sort-Object -Unique` |
| 15 | "Đếm tổng số dòng trong `var/log/app/2026/06/01/app.log`." | `wc -l` / `(Get-Content).Count` |
| 16 | "File `srv/digidinos-app/backend/config/staging.env` cần replace `staging` → `production` in-place trước khi deploy." | `sed -i 's/staging/production/g'` / `(Get-Content) -replace \| Set-Content` |
| 17 | "Lấy cột `cpu_usage` (cột 2) từ `server-metrics.txt` để vẽ chart (tạo file này trong `/opt/backups/daily`)." | `awk '{print $2}'` / `ForEach-Object { ($_ -split '\s+')[1] }` |
| 18 | "Append dòng `Note: Brute force blocked at 11:00` vào cuối `opt/backups/daily/report_20260601.txt`." | `echo "text" >> file` / `Add-Content` |
| 19 | "Lấy 10 dòng đầu `var/log/app/2026/06/01/app.log` để xem server khởi động như thế nào." | `head -10` / `Select-Object -First 10` |
| 20 | "Lấy 5 dòng cuối `var/log/app/2026/06/02/app.log` để xem lỗi mới nhất hôm nay." | `tail -5` / `Select-Object -Last 5` |
| 21 | "Xóa dòng trống trong `etc/nginx/conf.d/gzip.conf` cho gọn." | `grep -v '^$'` / `Where-Object { $_ -ne '' }` |
| 22 | "Tìm trong `var/log/app/2026/06/01/app.log` những dòng KHÔNG phải INFO — chỉ giữ WARN và ERROR." | `grep -v "INFO"` / `Where-Object { $_ -notmatch "INFO" }` |
| 23 | "Trim khoảng trắng thừa đầu/cuối mỗi dòng trong `etc/nginx/conf.d/gzip.conf`." | `sed 's/^ *//;s/ *$//'` / `ForEach-Object { $_.Trim() }` |
| 24 | "Đọc nội dung `opt/backups/daily/report_20260601.txt` và tìm dòng chứa chữ `Revenue`." | `grep "Revenue"` / `Select-String "Revenue"` |
| 25 | "Merge log ngày 01 và 02 thành 1 file để review toàn bộ — lưu vào `/opt/backups/daily/app_june.log`." | `cat f1 f2 > merged` / `Get-Content f1,f2 \| Set-Content merged` |

---

## 🟢 Sprint 3 — Kết hợp (Tổng hợp)

| # | Task từ leader | Kỹ thuật |
|---|---------------|---------|
| 26 | "Tìm tất cả file `.log` trong `/var/log` có chứa `OutOfMemory` — báo cáo khẩn DevOps." | find + grep / Get-ChildItem \| Select-String |
| 27 | "Đếm số lần mỗi service (`AuthService`, `PaymentService`...) xuất hiện trong log ngày 01." | grep + sort + uniq -c / Select-String + Group-Object |
| 28 | "Lấy IP unique bị 401 trong `access.log`, sort, lưu vào `opt/backups/daily/suspicious_ips.txt`." | grep + awk + sort -u / Select-String + ForEach + Sort -Unique + Set-Content |
| 29 | "Từ log, tìm tất cả đường dẫn file upload thật sự được ghi vào (dòng chứa `/home/deploy/uploads`)." | grep + cut / Select-String + ForEach |
| 30 | "Script `cleanup.sh` dùng `find ... -mtime +1 -delete` — viết lại đoạn đó bằng PowerShell." | Chuyển đổi bash → PowerShell thuần |

---

## 💡 Quy tắc thực hành

1. Đứng ở root `thuc-hanh-lenh/` như đứng ở `/` trên server thật.
2. Đọc task → tự nghĩ lệnh → chạy → xem output.
3. Sau mỗi task, viết cả 2 phiên bản Linux + PowerShell vào một file `answers.md` riêng.
4. Task 16 và 30 có side effect — chạy xong nhớ kiểm tra file thay đổi đúng chưa.
