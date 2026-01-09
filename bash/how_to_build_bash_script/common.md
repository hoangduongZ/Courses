# Linux Commands - Hướng Dẫn Thực Hành

## 1. Di Chuyển & Xem Thư Mục

### Các lệnh cơ bản
```bash
pwd                 # Xem thư mục hiện tại
ls                  # Liệt kê file/folder
ls -la              # Liệt kê chi tiết, bao gồm file ẩn
cd /path/to/dir     # Chuyển đến thư mục
cd ..               # Lùi 1 cấp
cd ~                # Về thư mục home
cd -                # Quay lại thư mục trước đó
```

### Thực hành
```bash
# Xem bạn đang ở đâu
pwd

# Liệt kê tất cả file
ls -la

# Chuyển vào thư mục Documents
cd Documents

# Quay lại home
cd ~
```

---

## 2. Thao Tác File & Thư Mục

### Tạo, xóa, di chuyển
```bash
# Tạo thư mục
mkdir folder_name
mkdir -p parent/child/grandchild    # Tạo nhiều cấp

# Tạo file rỗng
touch file.txt

# Sao chép
cp file.txt backup.txt              # Copy file
cp -r folder/ backup_folder/        # Copy thư mục

# Di chuyển/đổi tên
mv old_name.txt new_name.txt        # Đổi tên
mv file.txt /path/to/destination/   # Di chuyển

# Xóa
rm file.txt                         # Xóa file
rm -r folder/                       # Xóa thư mục
rm -rf folder/                      # Xóa không hỏi (cẩn thận!)
```

### Thực hành
```bash
# Tạo thư mục test
mkdir test_folder

# Tạo file bên trong
cd test_folder
touch demo.txt

# Copy file
cp demo.txt demo_backup.txt

# Xóa file backup
rm demo_backup.txt
```

---

## 3. Xem & Xử Lý Nội Dung File

### Vi/Vim - Trình soạn thảo phổ biến nhất

**Lưu ý:** `vi` và `vim` trên hầu hết hệ thống hiện đại là giống nhau. Gõ `vi` hay `vim` đều được!

#### Mở file
```bash
vi filename.txt         # Cách gõ ngắn (phổ biến)
vim filename.txt        # Cách gõ đầy đủ
```

#### Các chế độ trong Vim
- **Normal mode**: Chế độ mặc định (nhấn `ESC`)
- **Insert mode**: Chế độ chỉnh sửa (nhấn `i`)
- **Command mode**: Chế độ lệnh (nhấn `:`)

#### Các lệnh thường dùng
```vim
# Vào chế độ Insert (chỉnh sửa)
i           # Insert tại vị trí con trỏ
a           # Insert sau con trỏ
o           # Tạo dòng mới bên dưới

# Di chuyển (trong Normal mode)
h j k l     # Trái, xuống, lên, phải
gg          # Về đầu file
G           # Về cuối file
:10         # Nhảy đến dòng 10

# Copy, paste, xóa
yy          # Copy dòng hiện tại
dd          # Xóa/cắt dòng hiện tại
p           # Paste
u           # Undolt
Ctrl+r      # Redo

# Tìm kiếm
/text       # Tìm "text"
n           # Kết quả tiếp theo
N           # Kết quả trước đó

# Lưu và thoát
:w          # Lưu
:q          # Thoát
:wq         # Lưu và thoát
:q!         # Thoát không lưu
```

### Các lệnh xem file khác (không chỉnh sửa)
```bash
cat file.txt            # Xem toàn bộ file
less file.txt           # Xem từng trang (q để thoát)
head file.txt           # Xem 10 dòng đầu
head -n 20 file.txt     # Xem 20 dòng đầu
tail file.txt           # Xem 10 dòng cuối
tail -f log.txt         # Theo dõi file log real-time
```

### Thực hành Vi/Vim
```bash
# Tạo và mở file
vi practice.txt         # hoặc vim practice.txt

# Trong Vi/Vim:
# 1. Nhấn 'i' để vào Insert mode
# 2. Gõ: "Hello Linux! This is my first vim file."
# 3. Nhấn ESC để về Normal mode
# 4. Gõ ':wq' để lưu và thoát

# Xem file vừa tạo
cat practice.txt
```

---

## 3.5. Xử Lý Text với SED (Stream Editor)

### Sed là gì?
**Sed** là công cụ xử lý text mạnh mẽ, dùng để tìm và thay thế text trong file/stream mà không cần mở editor.

### Các lệnh SED cơ bản

#### 1. Tìm và thay thế
```bash
# Thay thế lần xuất hiện đầu tiên trên mỗi dòng
sed 's/old/new/' file.txt

# Thay thế TẤT CẢ trong file
sed 's/old/new/g' file.txt

# Lưu kết quả vào file mới
sed 's/old/new/g' file.txt > new_file.txt

# Sửa trực tiếp file gốc (cẩn thận!)
sed -i 's/old/new/g' file.txt

# Backup trước khi sửa
sed -i.bak 's/old/new/g' file.txt
```

#### 2. Xóa dòng
```bash
# Xóa dòng 3
sed '3d' file.txt

# Xóa dòng 2 đến 5
sed '2,5d' file.txt

# Xóa dòng cuối
sed '$d' file.txt

# Xóa dòng rỗng
sed '/^$/d' file.txt

# Xóa dòng chứa "pattern"
sed '/pattern/d' file.txt
```

#### 3. In dòng cụ thể
```bash
# In dòng 5
sed -n '5p' file.txt

# In dòng 10-20
sed -n '10,20p' file.txt

# In dòng chứa "error"
sed -n '/error/p' file.txt
```

#### 4. Thêm text
```bash
# Thêm text trước dòng 1
sed '1i\New first line' file.txt

# Thêm text sau dòng 3
sed '3a\New line after line 3' file.txt

# Thêm text trước dòng chứa "pattern"
sed '/pattern/i\Text before pattern' file.txt
```

#### 5. Thay thế nâng cao
```bash
# Không phân biệt hoa thường
sed 's/error/ERROR/gi' file.txt

# Thay thế chỉ dòng 2
sed '2s/old/new/' file.txt

# Thay thế từ dòng 5-10
sed '5,10s/old/new/g' file.txt

# Thay thế dòng chứa "pattern"
sed '/pattern/s/old/new/g' file.txt
```

### Ví dụ thực tế

#### Ví dụ 1: Sửa config file
```bash
# File config.txt:
# server=localhost
# port=8080
# debug=true

# Đổi port
sed -i 's/port=8080/port=3000/' config.txt

# Đổi localhost thành IP
sed -i 's/localhost/192.168.1.100/' config.txt
```

#### Ví dụ 2: Xử lý log file
```bash
# Xóa tất cả dòng INFO, chỉ giữ ERROR
sed '/INFO/d' app.log > errors_only.log

# Đổi tất cả WARNING thành WARN
sed 's/WARNING/WARN/g' app.log

# In chỉ các dòng ERROR
sed -n '/ERROR/p' app.log
```

#### Ví dụ 3: Xử lý CSV
```bash
# File data.csv:
# name,age,city
# John,25,Hanoi
# Jane,30,HCMC

# Đổi dấu phân cách từ , sang |
sed 's/,/|/g' data.csv

# Đổi tên thành phố
sed 's/Hanoi/Ha Noi/g' data.csv
```

#### Ví dụ 4: Thêm comment vào code
```bash
# Thêm comment ở đầu file
sed '1i\# This is a config file' config.txt

# Thêm comment trước mỗi dòng
sed 's/^/# /' script.sh
```

### Kết hợp Sed với lệnh khác
```bash
# Tìm file và thay thế
find . -name "*.txt" -exec sed -i 's/old/new/g' {} \;

# Xem log realtime và filter
tail -f app.log | sed -n '/ERROR/p'

# Kết hợp với grep
grep "user" file.txt | sed 's/user/USER/g'
```

### So sánh Vi/Vim vs Sed

| Tiêu chí | Vi/Vim | Sed |
|----------|--------|-----|
| **Khi nào dùng** | Chỉnh sửa thủ công, đọc file | Xử lý tự động, batch |
| **Tương tác** | Có (mở editor) | Không (chạy xong thoát) |
| **Tốc độ** | Chậm hơn | Rất nhanh |
| **Script** | Khó | Dễ dàng |
| **Undo** | Có | Không (trừ backup) |

### Thực hành Sed
```bash
# Tạo file test
cat > users.txt << EOF
user1:active
user2:inactive
user3:active
admin:active
EOF

# Xem file
cat users.txt

# Đổi tất cả "active" thành "ACTIVE"
sed 's/active/ACTIVE/g' users.txt

# Xóa user2
sed '/user2/d' users.txt

# Thay thế và lưu
sed 's/inactive/DISABLED/g' users.txt > users_new.txt
cat users_new.txt
```

---

## 4. Tìm Kiếm File

```bash
# Tìm file theo tên
find /path -name "filename.txt"
find . -name "*.txt"                # Tìm tất cả file .txt

# Tìm file theo kích thước
find . -size +100M                  # File > 100MB

# Tìm và xóa
find . -name "*.tmp" -delete

# Tìm kiếm text trong file
grep "text" file.txt
grep -r "text" /path/               # Tìm đệ quy trong thư mục
grep -i "text" file.txt             # Không phân biệt hoa thường
```

---

## 5. Phân Quyền File & User

### Hiểu về quyền trong Linux
```
-rw-r--r--  1 user group 1234 Dec 4 10:00 file.txt
│││││││││
│││││││││
│└┴┴┴┴┴┴┴── Quyền truy cập
└────────── Loại file (- = file, d = directory)

rwx rwx rwx
│   │   │
│   │   └── Others (người khác)
│   └────── Group (nhóm)
└────────── Owner (chủ sở hữu)

r = read (4)
w = write (2)
x = execute (1)
```

### Thay đổi quyền
```bash
# Dùng số (khuyến nghị)
chmod 755 script.sh     # rwxr-xr-x
chmod 644 file.txt      # rw-r--r--
chmod 600 secret.txt    # rw-------

# Dùng ký hiệu
chmod +x script.sh      # Thêm quyền execute
chmod -w file.txt       # Bỏ quyền write
chmod u+x file.sh       # User thêm execute
chmod g-w file.txt      # Group bỏ write
chmod o+r file.txt      # Others thêm read
```

### Quyền thư mục quan trọng
```bash
chmod 755 folder/       # Thư mục chuẩn
chmod 700 private/      # Thư mục riêng tư
```

### Thay đổi chủ sở hữu
```bash
# Chỉ root hoặc sudo mới làm được
sudo chown user:group file.txt
sudo chown -R user:group folder/    # Đệ quy
```

### Quản lý User
```bash
# Xem user hiện tại
whoami
id

# Thêm user mới (cần sudo)
sudo adduser username

# Xóa user
sudo deluser username

# Đổi password
passwd                      # Đổi password của mình
sudo passwd username        # Đổi password user khác

# Chuyển sang user khác
su - username
sudo su                     # Chuyển sang root
```

### Thực hành phân quyền
```bash
# Tạo file test
touch myfile.txt

# Xem quyền hiện tại
ls -l myfile.txt

# Chỉ mình đọc được
chmod 600 myfile.txt
ls -l myfile.txt

# Ai cũng đọc được nhưng chỉ mình ghi được
chmod 644 myfile.txt
ls -l myfile.txt

# Tạo script và cho phép chạy
touch script.sh
chmod +x script.sh
ls -l script.sh
```

---

## 6. Các Lệnh Hệ Thống Hữu Ích

### Thông tin hệ thống
```bash
df -h               # Dung lượng ổ đĩa
du -sh folder/      # Kích thước thư mục
free -h             # RAM
top                 # Tiến trình đang chạy (q để thoát)
htop                # Top nhưng đẹp hơn (cần cài)
ps aux              # Liệt kê tiến trình
```

### Mạng
```bash
ping google.com     # Test kết nối
ifconfig            # IP address (hoặc ip a)
wget URL            # Tải file
curl URL            # Gọi HTTP request
```

### Nén và giải nén
```bash
# Tar.gz (phổ biến nhất)
tar -czf archive.tar.gz folder/     # Nén
tar -xzf archive.tar.gz             # Giải nén

# Zip
zip -r archive.zip folder/          # Nén
unzip archive.zip                   # Giải nén
```

---

## 7. Tips & Tricks

### Shortcuts quan trọng
```bash
Ctrl + C        # Dừng lệnh đang chạy
Ctrl + Z        # Tạm dừng lệnh
Ctrl + L        # Xóa màn hình (hoặc 'clear')
Tab             # Tự động hoàn thành
Ctrl + R        # Tìm lệnh đã dùng
!!              # Chạy lại lệnh vừa rồi
sudo !!         # Chạy lại với sudo
```

### Lịch sử lệnh
```bash
history         # Xem lịch sử lệnh
!123            # Chạy lệnh số 123 trong history
history | grep "text"   # Tìm lệnh trong history
```

### Chuyển hướng output
```bash
command > file.txt      # Ghi output vào file (ghi đè)
command >> file.txt     # Ghi thêm vào cuối file
command 2> error.log    # Ghi error vào file
command &> all.log      # Ghi cả output và error
```

---

## 8. Kịch Bản Thực Hành Tổng Hợp

### Bài tập 1: Tạo project structure
```bash
# Tạo cấu trúc thư mục cho 1 project web
mkdir -p myproject/{src,public,config}
cd myproject
touch README.md
touch src/index.js
touch public/index.html
touch config/config.json

# Xem cấu trúc
ls -R
```

### Bài tập 2: Quản lý log files
```bash
# Tạo file log giả lập
mkdir logs
cd logs
echo "Error: Connection failed" > app.log
echo "Warning: Low memory" >> app.log
echo "Info: Server started" >> app.log

# Xem log
cat app.log
tail -f app.log     # (Ctrl+C để thoát)

# Tìm lỗi
grep "Error" app.log

# Backup log
cp app.log app.log.backup
gzip app.log.backup
```

### Bài tập 3: Script đơn giản
```bash
# Tạo script backup
vim backup.sh

# Nội dung script (nhấn i để insert):
#!/bin/bash
DATE=$(date +%Y%m%d)
mkdir -p backups
cp -r src/ backups/src_$DATE
echo "Backup completed: backups/src_$DATE"

# Lưu và thoát (:wq)

# Cho phép chạy
chmod +x backup.sh

# Chạy script
./backup.sh
```

---

## 9. Checklist Học Tập

- [ ] Di chuyển thành thạo giữa các thư mục
- [ ] Tạo, xóa, copy file và folder
- [ ] Sử dụng Vi/Vim để chỉnh sửa file
- [ ] Dùng Sed để tìm/thay thế text tự động
- [ ] Hiểu và áp dụng phân quyền 755, 644, 600
- [ ] Tìm kiếm file với find và grep
- [ ] Quản lý user cơ bản
- [ ] Nén và giải nén file
- [ ] Xem log và theo dõi file
- [ ] Viết script bash đơn giản

---

## 10. Tài Nguyên Học Thêm

- `man command` - Xem hướng dẫn chi tiết của lệnh
- `command --help` - Xem trợ giúp nhanh
- Practice: Tạo máy ảo Ubuntu hoặc dùng WSL trên Windows

**Lời khuyên**: Đừng cố nhớ tất cả, hãy thực hành thường xuyên. Khi cần, dùng `man` hoặc `--help`!