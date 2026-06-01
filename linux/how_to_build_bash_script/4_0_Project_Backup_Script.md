# 💼 **Project: Backup Script**

---

## 🎯 **Mục tiêu dự án**

Trong dự án này, bạn sẽ đóng vai **một kỹ sư hệ thống** được giao nhiệm vụ tạo **một Bash script tự động backup toàn bộ file trong thư mục Home của bạn**.

Dự án này giúp bạn:
- Ứng dụng kiến thức đã học về **cấu trúc script chuyên nghiệp**.  
- Thực hành **đặt quyền truy cập an toàn (secure permissions)** cho file script.  
- Làm quen với quy trình **viết, kiểm thử và triển khai** script thực tế.

---

## 🧩 **1. Yêu cầu bài toán**

👨‍💼 Sếp bạn nói:

> “Hãy viết cho tôi một script có thể backup tất cả các file trong thư mục home của bạn vào một file nén, đặt trong thư mục backup riêng.  
> Script phải có phần mô tả, thông tin tác giả và được bảo vệ an toàn khỏi người khác chỉnh sửa.”

---

## 📘 **2. Kế hoạch thực hiện**

| Bước | Hành động | Mục tiêu |
|------|------------|----------|
| 1️⃣ | Xác định **thư mục nguồn (home)** và **thư mục lưu trữ (backup)** | Chọn đường dẫn phù hợp cho script |
| 2️⃣ | Tạo **script khung chuẩn** với header, comment, usage | Giúp người khác hiểu và sử dụng dễ dàng |
| 3️⃣ | Viết logic backup bằng `tar` hoặc `rsync` | Tự động nén và lưu bản sao dữ liệu |
| 4️⃣ | Thiết lập quyền file với `chmod` | Bảo mật script khỏi người khác |
| 5️⃣ | Kiểm tra và chạy thử | Đảm bảo script hoạt động đúng và an toàn |

---

## ⚙️ **3. Gợi ý cấu trúc script**

### Tạo file:
```bash
nano backup_home.sh
```

### Nội dung mẫu:
```bash
#!/bin/bash
# ==========================================================
# Script Name:    backup_home.sh
# Description:    Compresses and backs up all files in the user's home directory.
# Author:         Hoang Duong
# Created Date:   2025-11-06
# Version:        1.0
# Usage:          ./backup_home.sh
# ==========================================================

# Thư mục cần backup (thư mục home)
SOURCE_DIR="$HOME"

# Thư mục lưu trữ file backup
BACKUP_DIR="$HOME/backups"

# Tên file backup (theo ngày tháng)
BACKUP_FILE="$BACKUP_DIR/home_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

# Kiểm tra và tạo thư mục backup nếu chưa có
if [ ! -d "$BACKUP_DIR" ]; then
  echo "📂 Creating backup directory at $BACKUP_DIR..."
  mkdir -p "$BACKUP_DIR"
fi

# Thực hiện nén dữ liệu
echo "🗜️ Compressing files from $SOURCE_DIR..."
tar -czf "$BACKUP_FILE" "$SOURCE_DIR" 2>/dev/null

# Kiểm tra kết quả
if [ $? -eq 0 ]; then
  echo "✅ Backup completed successfully!"
  echo "📦 Backup file created: $BACKUP_FILE"
else
  echo "❌ Backup failed!"
fi
```

---

## 🔒 **4. Đặt quyền truy cập an toàn**

Sau khi lưu file:

```bash
chmod 700 backup_home.sh
```

- `7` (rwx): bạn có thể đọc, ghi, chạy.  
- `0` (---): người khác không có quyền gì.  

Kiểm tra:
```bash
ls -l backup_home.sh
```

Kết quả mong đợi:
```
-rwx------ 1 hoang user 745 Nov 6 20:35 backup_home.sh
```

---

## 🧠 **5. Nâng cao (tuỳ chọn)**

Nếu bạn muốn làm script chuyên nghiệp hơn, có thể thêm:

### ✅ **Thông báo lỗi rõ ràng**
```bash
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory not found!"
  exit 1
fi
```

### ✅ **Ghi log vào file riêng**
```bash
LOG_FILE="$BACKUP_DIR/backup.log"
echo "$(date): Backup completed at $BACKUP_FILE" >> "$LOG_FILE"
```

### ✅ **Xoá backup cũ (giữ 7 bản gần nhất)**
```bash
ls -t "$BACKUP_DIR"/home_backup_*.tar.gz | tail -n +8 | xargs rm -f
```

---

## 🧩 **6. Bài tập thực hành**

### 🧱 **Bài tập 1:**
- Viết lại script backup của riêng bạn.
- Thêm thông tin:
  - Mô tả chi tiết hơn.
  - Thời gian bắt đầu & kết thúc backup.
  - Kích thước file backup (`du -h`).

### 🧱 **Bài tập 2:**
- Thiết lập cronjob tự động chạy script mỗi ngày:
```bash
crontab -e
```
Thêm dòng:
```
0 2 * * * /home/hoang/backup_home.sh
```
➡ Script sẽ chạy **mỗi ngày lúc 2 giờ sáng**.

---

## 📘 **7. Kiểm tra kiến thức**

| Câu hỏi | Đáp án gợi ý |
|----------|---------------|
| 1️⃣ Lệnh nào dùng để thay đổi quyền truy cập file? | `chmod` |
| 2️⃣ Vì sao không nên để quyền `777` cho script? | Vì ai cũng có thể sửa hoặc xóa script, gây mất an toàn |
| 3️⃣ Lệnh nào dùng để nén file/thư mục trong Bash? | `tar -czf` |
| 4️⃣ Nên lưu backup ở đâu cho an toàn? | Thư mục `backups` riêng hoặc ổ cứng ngoài |

---

## 🧭 **8. Tổng kết dự án**

| Nội dung | Ý nghĩa |
|-----------|----------|
| Viết script có mô tả và comment | Giúp người khác hiểu rõ chức năng |
| Sử dụng `tar` để nén | Tiết kiệm dung lượng |
| Đặt quyền `700` | Bảo mật script |
| Thêm log và cleanup cũ | Tăng tính chuyên nghiệp |

---

> 💡 **Ghi nhớ:**  
> Một kỹ sư Bash chuyên nghiệp không chỉ viết script chạy được —  
> mà còn **viết script an toàn, dễ bảo trì và tự động hóa hiệu quả.**

---
