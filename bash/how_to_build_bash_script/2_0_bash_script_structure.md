# 🧭 Chủ đề: **Bash Script Structure – Part 1: Core Components**

## 🎯 Mục tiêu học tập
Sau khi hoàn thành bài học này, bạn sẽ có thể:
1. **Nhận diện các thành phần cốt lõi** của một Bash Script.  
2. **Giải thích vai trò** của từng thành phần đó.  
3. **Chạy một Bash Script** trên máy tính của mình.

---

## 🧩 Phần 1: Cấu trúc cơ bản của một Bash Script

Một Bash script là **file văn bản chứa các lệnh Bash**.  
Cấu trúc tiêu chuẩn bao gồm 3 phần chính:

```
#!/bin/bash        ← (1) Shebang
# This is a comment ← (2) Comment
echo "Hello Bash!" ← (3) Command
```

### 🔹 (1) Shebang Line – “#!”
- Dòng đầu tiên **luôn bắt đầu bằng `#!`** theo sau là đường dẫn đến trình thông dịch (interpreter).  
- Mục đích: Cho hệ điều hành biết **script này nên được chạy bằng chương trình nào**.

🧠 Ví dụ:
```bash
#!/bin/bash
```
Nghĩa là: “Chạy file này bằng Bash.”

Một số ví dụ khác:
| Shell | Shebang line |
|--------|---------------|
| Bash | `#!/bin/bash` |
| Sh (Bourne shell) | `#!/bin/sh` |
| Zsh | `#!/bin/zsh` |
| Python | `#!/usr/bin/python3` |

> ⚠️ Nếu thiếu dòng `#!`, hệ thống có thể không biết cách chạy script, hoặc chạy bằng shell khác ngoài Bash.

---

### 🔹 (2) Comments – Ghi chú trong mã
- Bắt đầu bằng dấu **`#`**, dùng để **mô tả ý nghĩa code**, giúp người khác (và chính bạn) hiểu rõ script.
- Comments **không được thực thi** khi chạy script.

🧠 Ví dụ:
```bash
# Đây là script chào mừng
echo "Hello, Hoang!"
```

💡 Tips:
- Dùng comments đầu file để ghi mô tả script, ví dụ:
```bash
#!/bin/bash
# Author: Hoàng Dương
# Description: Script này in ra lời chào với tên người dùng
```

---

### 🔹 (3) Commands – Lệnh Bash
- Là phần “nội dung chính” của script.  
- Bao gồm các **lệnh Bash** mà bạn muốn hệ thống thực thi: `echo`, `ls`, `pwd`, `cd`, `mkdir`, v.v.

🧠 Ví dụ:
```bash
#!/bin/bash
echo "Listing files..."
ls
echo "Done!"
```

---

## 🧩 Phần 2: Cách tạo và chạy Bash Script

### Bước 1️⃣ – Tạo file script
Tạo một file mới, ví dụ:  
```bash
touch hello.sh
```

### Bước 2️⃣ – Viết nội dung vào file bằng lệnh
```bash
# Sử dụng lệnh echo để ghi nội dung vào file
# Dòng đầu tiên: Shebang
echo "#!/bin/bash" > hello.sh

# Dòng thứ hai: Comment
echo "# Simple hello world script" >> hello.sh

# Dòng thứ ba: Command
echo "echo \"Hello, world!\"" >> hello.sh
```

### Bước 3️⃣ – Cấp quyền thực thi
```bash
chmod +x hello.sh
```
/
### Bước 4️⃣ – Chạy script
Có hai cách:
```bash
# Cách 1: Gọi trực tiếp nếu có quyền thực thi
./hello.sh

# Cách 2: Chạy thông qua Bash
bash hello.sh
```

---

## 🧠 Phần 3: Tóm tắt kiến thức

| Thành phần | Vai trò |
|-------------|----------|
| **Shebang (`#!/bin/bash`)** | Xác định chương trình dùng để chạy script |
| **Comment (`#`)** | Giúp mô tả, ghi chú nội dung code |
| **Commands** | Thực hiện hành động chính trong script |

---

## ⚙️ Phần 4: Bài tập thực hành

### 🧩 Bài 1: Viết script hiển thị thông tin hệ thống (không dùng giao diện)
Tạo file `sysinfo.sh` bằng lệnh:
```bash
# Tạo file và thêm dòng shebang
echo "#!/bin/bash" > sysinfo.sh

# Thêm comment mô tả script
echo "# Script hiển thị thông tin hệ thống" >> sysinfo.sh

# Thêm các lệnh hiển thị thông tin hệ thống
echo "echo \"Current user: $(whoami)\"" >> sysinfo.sh
echo "echo \"Home directory: $HOME\"" >> sysinfo.sh
echo "echo \"Current path: $(pwd)\"" >> sysinfo.sh
```

Cấp quyền và chạy:
```bash
chmod +x sysinfo.sh/
./sysinfo.sh
```

# Hướng dẫn chỉnh sửa dòng bị sai
# Nếu dòng lệnh bị sai, ví dụ:
echo "Current user: $(whoami)"

# Bạn có thể chỉnh sửa bằng cách sử dụng lệnh sau:
sed -i 's|echo \"Current user: $(whoami)\"|echo \"Current user: $(whoami)\"|' sysinfo.sh

# Lệnh này sẽ thay thế dòng sai bằng dòng đúng trong file sysinfo.sh.

---

## 🎓 Mini Quiz

1. Dòng `#!/bin/bash` trong script có nghĩa gì?  
   a. Là comment mô tả script  
   b. Là lệnh bắt buộc để khởi động Bash  
   ✅ c. Cho hệ thống biết dùng Bash để chạy file script  

2. Comment trong Bash được bắt đầu bằng ký tự nào?  
   ✅ `#`

3. Lệnh nào dùng để cấp quyền thực thi cho file script?  
   ✅ `chmod +x filename`

4. Cách nào đúng để chạy script `hello.sh` trong thư mục hiện tại?  
   ✅ `./hello.sh`

---

## 🧩 Tổng kết

| Mục tiêu | Đã đạt được |
|-----------|-------------|
| Nhận diện thành phần của Bash Script | ✅ |
| Hiểu vai trò từng phần | ✅ |
| Tự tạo và chạy script trên máy | ✅ |

---

> ✨ **Gợi ý bài tiếp theo:**  
> **“Bash Script Structure – Part 2: Variables and Arguments”** – tìm hiểu cách lưu trữ và sử dụng dữ liệu trong script.
