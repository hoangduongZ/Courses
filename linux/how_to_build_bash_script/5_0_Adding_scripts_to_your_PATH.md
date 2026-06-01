# 🧠 **Adding Scripts to Your PATH**

---

## 🎯 **Mục tiêu học tập**

Sau khi hoàn thành bài học này, bạn sẽ có thể:

1. **Giải thích mục đích của biến môi trường PATH** trong hệ thống.  
2. **Thêm thư mục mới vào PATH**, giúp hệ thống nhận diện được các script của bạn.  
3. **Chạy các script từ bất kỳ vị trí nào** trong terminal, giống như các lệnh hệ thống thông thường (như `ls`, `cd`, `mkdir`, ...).

---

## 🧩 **1. Giới thiệu về biến PATH**

### 🔍 PATH là gì?

`PATH` là **biến môi trường** (environment variable) trong Linux/Mac (và cả Windows), cho biết **hệ thống sẽ tìm lệnh ở đâu** khi bạn gõ một lệnh trong terminal.

Ví dụ:
```bash
echo $PATH
```

Kết quả có thể trông như sau:
```
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/home/hoang/.local/bin
```

➡ Mỗi thư mục trong danh sách này được ngăn cách bởi dấu hai chấm (`:`).  
Khi bạn gõ một lệnh, hệ thống sẽ **duyệt từng thư mục trong PATH** để tìm file thực thi tương ứng.

Ví dụ:
- Khi bạn gõ `python`, hệ thống sẽ tìm `python` trong `/usr/bin`, `/usr/local/bin`, v.v.
- Nếu không tìm thấy trong bất kỳ thư mục nào → báo lỗi:
  ```
  command not found
  ```

---

## ⚙️ **2. Tại sao nên thêm script của bạn vào PATH**

Nếu bạn viết script trong thư mục như:
```
/home/hoang/scripts/backup_home.sh
```

Bạn phải chạy bằng đường dẫn đầy đủ:
```bash
bash /home/hoang/scripts/backup_home.sh
```
hoặc
```bash
./backup_home.sh   # nếu đang ở đúng thư mục
```

➡ **Bất tiện** nếu bạn muốn gọi script từ mọi nơi.

💡 **Giải pháp:** thêm `/home/hoang/scripts` vào PATH  
→ để chỉ cần gõ:
```bash
backup_home.sh
```
ở bất kỳ đâu cũng chạy được ✅

---

## 🧠 **3. Cách thêm thư mục vào PATH tạm thời**

Bạn có thể thêm tạm thời (chỉ hiệu lực trong session hiện tại):

```bash
export PATH="$PATH:/home/hoang/scripts"
```

Kiểm tra lại:
```bash
echo $PATH
```
Kết quả sẽ thấy thư mục `/home/hoang/scripts` đã được thêm vào cuối.

Giờ thử:
```bash
backup_home.sh
```
➡ Script chạy thành công từ bất kỳ vị trí nào trong hệ thống!

> ⚠️ Khi bạn đóng terminal, cấu hình này sẽ **mất** (vì nó chỉ tồn tại trong session hiện tại).

---

## 🧩 **4. Cách thêm thư mục vào PATH vĩnh viễn**

Để cấu hình **vĩnh viễn**, bạn thêm dòng `export PATH=...` vào file cấu hình shell của bạn.

### ✅ Nếu dùng **bash**, thêm vào file:
- `~/.bashrc` (cho Linux)
- hoặc `~/.bash_profile` (cho macOS)

Thêm dòng sau:
```bash
export PATH="$PATH:$HOME/scripts"
```

Lưu lại, rồi chạy:
```bash
source ~/.bashrc
```
hoặc
```bash
source ~/.bash_profile
```
➡ Giúp shell **nạp lại** file cấu hình mà không cần đăng nhập lại.

Giờ bạn có thể chạy:
```bash
backup_home.sh
```
từ **mọi thư mục**!

---

## 🔐 **5. Quy tắc bảo mật khi thêm thư mục vào PATH**

- 🔒 **Không nên thêm thư mục có quyền ghi cho người khác** (ví dụ `/tmp`) — kẻ xấu có thể chèn script độc hại.  
- ✅ Chỉ nên thêm các thư mục **thuộc sở hữu của bạn**, ví dụ:
  ```
  /home/hoang/scripts
  /home/hoang/bin
  ```
- 🚫 Tránh ghi đè PATH mặc định. Luôn thêm vào **cuối**:
  ```bash
  export PATH="$PATH:/new/folder"
  ```
  Không nên làm:
  ```bash
  export PATH="/new/folder"
  ```
  (vì sẽ **xóa toàn bộ đường dẫn hệ thống mặc định**)

---

## 💻 **6. Ví dụ thực tế**

### 🧩 Tạo thư mục chứa script:
```bash
mkdir -p ~/scripts
```

### 🧩 Tạo script mẫu:
```bash
nano ~/scripts/sayhello.sh
```

### Nội dung:
```bash
#!/bin/bash
echo "Hello, $USER! Welcome to your Bash PATH setup!"
```

### Thêm quyền thực thi:
```bash
chmod +x ~/scripts/sayhello.sh
```

### Thêm vào PATH:
```bash
export PATH="$PATH:$HOME/scripts"
```

### Thử chạy:
```bash
sayhello.sh
```
Kết quả:
```
Hello, hoang! Welcome to your Bash PATH setup!
```

---

## 🧱 **7. Bài tập thực hành**

### 🔨 Bài tập 1:
1. Tạo thư mục `~/mytools`.  
2. Viết script `hello_user.sh` in ra “Hello <tên người dùng>”.  
3. Thêm thư mục `~/mytools` vào PATH.  
4. Thử chạy `hello_user.sh` từ một thư mục khác.

### 🔨 Bài tập 2:
- Tạo một script `sysinfo.sh` hiển thị:
  - Thời gian hiện tại (`date`)
  - Dung lượng đĩa còn trống (`df -h`)
  - Bộ nhớ RAM đang dùng (`free -h`)
- Lưu vào `~/scripts`
- Thêm vào PATH vĩnh viễn.

---

## 🧭 **8. Tổng kết kiến thức**

| Khái niệm | Ý nghĩa |
|------------|----------|
| `PATH` | Danh sách thư mục chứa lệnh thực thi |
| `echo $PATH` | Xem các thư mục hiện có trong PATH |
| `export PATH="$PATH:/path/to/dir"` | Thêm thư mục mới vào PATH |
| `source ~/.bashrc` | Nạp lại file cấu hình Bash |
| `chmod +x file.sh` | Cho phép script chạy được |
| Thêm vào cuối PATH | Giữ nguyên đường dẫn hệ thống gốc |

---

> 💡 **Ghi nhớ:**  
> Khi script của bạn nằm trong một thư mục có trong `PATH`,  
> bạn đã **biến nó thành một lệnh riêng của hệ thống** —  
> giống như cách bạn gõ `ls`, `cd`, hay `ping` vậy!

---
