# 🧭 Chủ đề: **Shells vs Scripts**

## 🎯 Mục tiêu học tập
Sau khi học xong bài này, bạn sẽ có thể:
1. Giải thích **sự khác nhau giữa Shell và Script**.  
2. Hiểu **vì sao Bash Shell phổ biến hơn các Shell khác**.  
3. Mô tả **lợi ích của việc viết script trong Bash**.

---

## 🧩 Phần 1: Khái niệm cơ bản

### 🔹 1.1 Shell là gì?
- **Shell** là một *chương trình trung gian* giữa người dùng và hệ điều hành (OS).  
- Nó nhận lệnh bạn nhập (commands), gửi chúng cho hệ điều hành để thực thi, rồi hiển thị kết quả.  
- Nói cách khác:  
  > **Shell = giao diện để nói chuyện với Linux/Unix.**

🧠 Ví dụ:
```bash
$ ls
$ cd /home
$ pwd
```
Mỗi dòng trên là một **lệnh Shell**, bạn gõ trực tiếp vào terminal.

### 🔹 1.2 Bash là gì?
- **Bash (Bourne Again SHell)** là một loại Shell, được phát triển dựa trên **Bourne Shell (sh)**.
- Bash là **mặc định** trong hầu hết các bản phân phối Linux và macOS.
- Một số Shell khác: `zsh`, `fish`, `ksh`, `tcsh` — nhưng **Bash phổ biến nhất** vì:
  - Miễn phí, mã nguồn mở.
  - Hỗ trợ **tự động hoàn thành**, **biến**, **điều kiện**, **vòng lặp**.
  - Có thể **viết script để tự động hóa công việc**.

---

## 🧩 Phần 2: Scripts là gì?

### 🔹 2.1 Script là gì?
- **Script** là **một tập hợp nhiều lệnh Shell** được viết trong **một file văn bản**, để hệ thống thực thi tuần tự.  
- Thay vì gõ thủ công từng lệnh, bạn chỉ cần chạy một file `.sh`.

🧠 Ví dụ:
Tạo file `hello.sh`
```bash
#!/bin/bash
echo "Hello, World!"
```

Chạy file:
```bash
$ bash hello.sh
```

Kết quả:
```
Hello, World!
```

👉 **Tóm lại:**

| So sánh | Shell | Script |
|----------|--------|---------|
| Cách dùng | Gõ lệnh trực tiếp | Lưu các lệnh trong file |
| Mục tiêu | Thực hiện tác vụ tức thì | Tự động hóa các tác vụ |
| Ví dụ | `ls`, `cd`, `pwd` | `backup.sh`, `deploy.sh` |

---

## 💡 Phần 3: Tại sao Bash lại phổ biến?

1. **Cài sẵn trên hầu hết hệ thống Linux/macOS.**  
2. **Tương thích cao** – nhiều script cũ vẫn chạy được.  
3. **Ngôn ngữ dễ học** – gần gũi với người dùng command line.  
4. **Tự động hóa mạnh mẽ** – dùng trong DevOps, CI/CD, hệ thống quản trị server.

---

## ⚙️ Phần 4: Lợi ích của việc viết script

1. **Tiết kiệm thời gian** — thay vì gõ lại 10 lệnh mỗi ngày.  
2. **Giảm lỗi do thao tác tay.**  
3. **Tự động hóa toàn bộ quy trình** (backup, deploy, build, test…).  
4. **Chia sẻ quy trình làm việc dễ dàng** — chỉ cần gửi file `.sh`.

---

## 🧠 Phần 5: Bài tập thực hành

### Bài 1 – Chạy lệnh thủ công:
Trong terminal, chạy lần lượt:
```bash
pwd
ls
whoami
```
→ Ghi lại kết quả.

### Bài 2 – Viết script tương tự:
Tạo file `myscript.sh`
```bash
#!/bin/bash
pwd
ls
whoami
```
Chạy file và so sánh kết quả với Bài 1.

---

## 🎓 Mini Quiz (kiểm tra nhanh)

1. Bash là gì?  
   a. Một loại hệ điều hành  
   b. Một trình biên dịch  
   ✅ c. Một Shell phổ biến trên Linux  

2. Shell và Script khác nhau ở điểm nào?  
   ✅ Shell chạy lệnh trực tiếp, Script chứa các lệnh lưu sẵn trong file.  

3. Viết script giúp ích gì?  
   ✅ Tự động hóa tác vụ, tiết kiệm thời gian, giảm sai sót.

---

## 🧩 Tổng kết

| Khái niệm | Mô tả |
|------------|--------|
| **Shell** | Giao diện lệnh để tương tác với OS |
| **Bash** | Một trong các Shell phổ biến nhất |
| **Script** | File chứa nhiều lệnh Bash để tự động hóa |
| **Lợi ích** | Tốc độ, hiệu quả, giảm sai sót, tái sử dụng |

---

> ✨ **Gợi ý bài tiếp theo:**  
> **“Bài 2: Cấu trúc và cú pháp cơ bản của Bash Script”** – tìm hiểu về `shebang`, `comment`, quyền thực thi, và cách chạy script.