# 🧠 **Bash Script Structure - Part 2: Professional Components**

---

## 🎯 **Mục tiêu học tập**

Sau khi hoàn thành bài học này, bạn sẽ có thể:

1. Giải thích **tại sao cần thêm thông tin mô tả và chú thích** trong bash script.  
2. Tạo **comment nội dòng (inline comments)** để làm rõ các phần logic trong code.  
3. Thêm **header chuyên nghiệp** chứa thông tin tác giả, ngày tạo, mô tả, và hướng dẫn sử dụng.  
4. Viết được **bash script chuẩn chuyên nghiệp**, dễ đọc – dễ bảo trì – dễ chia sẻ.

---

## 🧩 **1. Tổng quan**

Một bash script **có thể chạy được** chưa chắc đã là **script tốt**.  
Script chuyên nghiệp cần:

- Dễ hiểu với người k[oihác (hoặc chính bạn trong tương lai).  
- Có mô tả rõ ràng về **chức năng, cách chạy, tác giả, và ngày sửa đổi**.  
- Có chú thích từng phần giúp **người đọc dễ nắm logic**.  

---

## ⚙️ **2. Cấu trúc cơ bản của một script chuyên nghiệp**

Một script chuyên nghiệp thường bắt đầu với phần **header**, ví dụ:

```bash
#!/bin/bash
# ==========================================================
# Script Name:    backup_logs.sh
# Description:    This script compresses and archives log files.
# Author:         Hoang Duong
# Created Date:   2025-11-06
# Last Modified:  2025-11-06
# Version:        1.0
# Usage:          ./backup_logs.sh [source_directory] [destination_directory]
# ==========================================================
```

### 📘 Giải thích từng dòng:
| Thành phần | Ý nghĩa |
|-------------|----------|
| `#!/bin/bash` | Chỉ định rằng script này sẽ được chạy bằng bash shell. |
| `# Script Name:` | Tên script – giúp nhận diện nhanh trong thư mục chứa nhiều script. |
| `# Description:` | Mô tả chức năng tổng quát của script. |
| `# Author:` | Ghi rõ người tạo – giúp theo dõi trách nhiệm và liên hệ. |
| `# Created Date:` / `# Last Modified:` | Theo dõi lịch sử phát triển hoặc bảo trì script. |
| `# Version:` | Dành cho các script có thể được cập nhật thường xuyên. |
| `# Usage:` | Hướng dẫn người dùng cách chạy script (tham số cần thiết, cú pháp, v.v.). |

---

## 💬 **3. Cách viết comment chuyên nghiệp**

### 🧱 Loại 1: Comment mô tả khối lệnh

```bash
# Kiểm tra nếu người dùng không nhập đủ 2 đối số
if [ $# -ne 2 ]; then
  echo "Usage: ./backup_logs.sh [source_directory] [destination_directory]"
  exit 1
fi
```

🟢 **Giải thích:** comment nằm **ngay trên khối code** → giúp người đọc hiểu “code sắp làm gì”.

---

### 🧱 Loại 2: Comment nội dòng (inline comment)

```bash
tar -czf "$2/logs_$(date +%Y%m%d).tar.gz" "$1"  # Tạo file nén từ thư mục nguồn
```

🟢 **Giải thích:** comment ở **cuối dòng code** → giúp mô tả nhanh mà không làm ngắt dòng.

---

## 💡 **4. Ví dụ hoàn chỉnh: Script chuyên nghiệp**

```bash
#!/bin/bash
# ==========================================================
# Script Name:    backup_logs.sh
# Description:    Compress and archive log files to a destination folder.
# Author:         Hoang Duong
# Created Date:   2025-11-06
# Last Modified:  2025-11-06
# Version:        1.0
# Usage:          ./backup_logs.sh [source_directory] [destination_directory]
# ==========================================================

# Kiểm tra nếu thiếu đối số truyền vào
if [ $# -ne 2 ]; then
  echo "Usage: ./backup_logs.sh [source_directory] [destination_directory]"
  exit 1
fi

# Gán biến đầu vào
SOURCE_DIR=$1
DEST_DIR=$2

# Kiểm tra xem thư mục nguồn có tồn tại không
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory does not exist."
  exit 1
fi

# Tạo file nén với ngày hiện tại
tar -czf "$DEST_DIR/logs_$(date +%Y%m%d).tar.gz" "$SOURCE_DIR"

# Thông báo hoàn thành
echo "✅ Backup completed successfully!"
```

---

## 🧠 **5. Thực hành: Viết script chuyên nghiệp của riêng bạn**

### 🔨 Bài tập:
Tạo file `system_info.sh` có nội dung:

- Hiển thị:
  - Ngày và giờ hiện tại.
  - Tên người dùng đang đăng nhập.
  - Dung lượng đĩa trống.
- Có phần **header** đầy đủ thông tin.
- Có ít nhất **3 comment nội dòng hoặc khối** mô tả logic code.

### Gợi ý mẫu:
```bash
#!/bin/bash
# ==========================================================
# Script Name:    system_info.sh
# Description:    Display current system information.
# Author:         <Your Name>
# Created Date:   <Date>
# Usage:          ./system_info.sh
# ==========================================================

# Hiển thị thời gian hiện tại
echo "Current date and time: $(date)"

# Hiển thị tên người dùng
echo "User: $USER"

# Hiển thị dung lượng đĩa còn trống
echo "Disk usage:"
df -h
```

---

## 📘 **6. Tổng kết kiến thức**

| Khái niệm | Ý nghĩa | Ví dụ |
|------------|----------|--------|
| Header | Thông tin giới thiệu script | Author, Description, Usage |
| Comment khối | Mô tả logic cho 1 đoạn code | `# Check input arguments` |
| Comment nội dòng | Ghi chú ngắn ngay sau câu lệnh | `# Create archive file` |
| Usage | Hướng dẫn chạy script | `Usage: ./script.sh arg1 arg2` |

---

## 🧩 **7. Bài tập mở rộng**
- Chỉnh sửa lại một script cũ của bạn, thêm header và comment hợp lý.  
- Viết script `cleanup_temp.sh` để xóa file tạm (`*.tmp`) trong thư mục `/tmp`, có header và usage rõ ràng.  

---

> 💡 **Ghi nhớ:**  
> Một script chuyên nghiệp **luôn tự nói lên được ý nghĩa của nó** mà không cần bạn phải giải thích bằng miệng.

---
