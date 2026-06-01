# 🧠 **Setting up Secure Script Permissions**

---

## 🎯 **Mục tiêu học tập**

Sau khi hoàn thành bài học này, bạn sẽ có thể:

1. **Nhận biết các loại quyền truy cập file (file permissions)** trong Linux.  
2. **Hiểu ý nghĩa** của từng quyền đối với người dùng, nhóm, và người khác.  
3. **Thiết lập quyền an toàn cho bash script**, tránh rủi ro bảo mật khi chia sẻ hoặc chạy script trên hệ thống.

---

## 🧩 **1. Giới thiệu về File Permissions trong Linux**

Trong Linux, **mỗi file và thư mục** đều có một tập hợp quyền xác định *ai có thể đọc, ghi, hoặc thực thi* nó.  
Cấu trúc quyền thường hiển thị khi bạn dùng lệnh:

```bash
ls -l
```

Ví dụ kết quả:

```
-rwxr-xr--
```

### 📘 Phân tích từng phần:

| Vị trí | Ký tự | Ý nghĩa |
|--------|--------|----------|
| 1 | `-` | Loại file (`-` là file thường, `d` là thư mục) |
| 2–4 | `rwx` | Quyền của **chủ sở hữu (owner)** |
| 5–7 | `r-x` | Quyền của **nhóm (group)** |
| 8–10 | `r--` | Quyền của **người khác (others)** |

---

## ⚙️ **2. Các quyền cơ bản**

| Ký tự | Tên quyền | Ý nghĩa |
|--------|------------|----------|
| `r` | Read | Được phép đọc nội dung file |
| `w` | Write | Được phép chỉnh sửa hoặc xóa file |
| `x` | Execute | Được phép thực thi file như một chương trình/script |

Ví dụ:
```
-rwxr-xr--
```
➡ Nghĩa là:
- **Chủ sở hữu:** có quyền đọc, ghi, chạy (`rwx`)  
- **Nhóm:** chỉ đọc và chạy (`r-x`)  
- **Người khác:** chỉ đọc (`r--`)

---

## 🔐 **3. Tại sao cần đặt quyền đúng cho script**

Nếu bạn cho phép **quá nhiều quyền**, có thể gây:
- Người khác **chỉnh sửa hoặc xóa** script của bạn.
- Người khác **chạy script với mã độc hại** (nếu họ chèn được code vào).
- Lộ **thông tin nhạy cảm** trong file (ví dụ: mật khẩu, API key, v.v.).

Ngược lại, nếu quyền quá chặt:
- Ngay cả bạn cũng **không thể chạy script**.

🎯 Vì vậy, **phải đặt quyền hợp lý để an toàn và tiện sử dụng.**

---

## 🧠 **4. Lệnh `chmod` – thay đổi quyền truy cập**

### Cấu trúc:
```bash
chmod [quyền] [tên_file]
```

### Hai cách sử dụng phổ biến:

#### 🧩 Cách 1: Dùng **ký tự**
```bash
chmod u+x script.sh   # Thêm quyền chạy cho user
chmod g-w script.sh   # Bỏ quyền ghi cho group
chmod o-r script.sh   # Bỏ quyền đọc cho others
```

#### 🧩 Cách 2: Dùng **số (octal)**
| Số | Quyền | Mô tả |
|----|--------|--------|
| 7 | rwx | Đọc + Ghi + Chạy |
| 6 | rw- | Đọc + Ghi |
| 5 | r-x | Đọc + Chạy |
| 4 | r-- | Chỉ đọc |
| 0 | --- | Không có quyền |

Ví dụ:
```bash
chmod 700 script.sh   # Chỉ owner có quyền đọc, ghi, chạy
chmod 755 script.sh   # Owner: rwx | Group: r-x | Others: r-x
chmod 744 script.sh   # Owner: rwx | Group: r-- | Others: r--
```

---

## 🔰 **5. Quy tắc an toàn khi cấp quyền cho script**

| Tình huống | Quyền khuyên dùng | Giải thích |
|-------------|--------------------|-------------|
| Script cá nhân | `700` | Chỉ bạn mới được đọc/chạy |
| Script dùng trong nhóm | `750` | Nhóm được chạy, không chỉnh sửa |
| Script công khai | `755` | Mọi người có thể chạy, không chỉnh sửa |
| File chứa thông tin nhạy cảm (password, API key) | `600` | Chỉ bạn được đọc/ghi |

---

## 💻 **6. Ví dụ thực tế**

### Tạo file script:
```bash
nano secure_backup.sh
```

### Nội dung:
```bash
#!/bin/bash
# Secure Backup Script
# Author: Hoang Duong
# Description: Compresses a folder securely.

tar -czf backup_$(date +%F).tar.gz /home/user/data
```

### Thiết lập quyền an toàn:
```bash
chmod 700 secure_backup.sh
```

### Kiểm tra quyền:
```bash
ls -l secure_backup.sh
```

Kết quả:
```
-rwx------ 1 hoang user 234 Nov 6 20:00 secure_backup.sh
```
👉 Chỉ người sở hữu (`hoang`) mới có thể đọc, ghi, chạy file này.

---

## 🧩 **7. Bài tập thực hành**

### 🔨 Bài tập 1:
Tạo file `test_script.sh` với nội dung:
```bash
#!/bin/bash
echo "Testing permissions!"
```
- Thêm quyền chạy chỉ cho bạn (user).  
- Thử chạy `./test_script.sh`  
- Sau đó thử chạy bằng người dùng khác → Quan sát kết quả.

### 🔨 Bài tập 2:
Tạo một file `shared_script.sh` mà:
- Bạn và nhóm cùng có thể chạy.
- Nhưng chỉ bạn mới được chỉnh sửa.  

👉 Gợi ý: dùng quyền `chmod 750`.

---

## 🧭 **8. Tổng kết kiến thức**

| Khái niệm | Ý nghĩa |
|------------|----------|
| `r` | Read – cho phép đọc file |
| `w` | Write – cho phép chỉnh sửa |
| `x` | Execute – cho phép chạy |
| `chmod` | Thay đổi quyền file |
| `ls -l` | Kiểm tra quyền hiện tại |
| Quyền an toàn nhất cho script cá nhân | `700` |

---

> 💡 **Ghi nhớ:**  
> Một script an toàn là script chỉ chạy được bởi người cần dùng,  
> không bao giờ nên cấp quyền ghi (`w`) cho người khác nếu không cần thiết.

---
