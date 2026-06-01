# Linux Commands - Hướng Dẫn Thực Hành
## Common linux for enterpise
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
-i: in place

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
i: insert
# Thêm text sau dòng 3
sed '3a\New line after line 3' file.txt
a: append
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
-n: no print không cho in hết ra ngay, đi qua bộ lọc trước
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

## 6. Pipes & Command Chaining (KẾT HỢP LỆNH)

> **Quan trọng!** Pipes là sức mạnh của Linux - kết hợp nhiều lệnh đơn giản thành công cụ mạnh mẽ.

### Pipe cơ bản (|)
```bash
# Output của lệnh trước → Input của lệnh sau
ls -la | grep "txt"                 # Liệt kê rồi lọc file .txt
ps aux | grep nginx                 # Tìm process nginx
history | grep "git"                # Tìm các lệnh git đã dùng

# Chain nhiều pipes
cat file.txt | grep "error" | wc -l # Đếm số dòng có "error"
ps aux | grep nginx | grep -v grep  # Loại bỏ dòng grep itself
```

### Redirection nâng cao
```bash
# Output redirection
command > file.txt          # Ghi đè (overwrite)
command >> file.txt         # Ghi thêm (append)
command 2> error.log        # Chỉ ghi error
command > output.txt 2>&1   # Ghi cả output và error
command &> all.log          # Ghi cả output và error (ngắn gọn)

# Input redirection
command < input.txt         # Đọc từ file
command << EOF              # Here document
line 1
line 2
EOF

# Tee - vừa xem vừa lưu
command | tee output.txt            # Vừa hiển thị vừa ghi file
command | tee -a output.txt         # Append thay vì overwrite
```

### Logical operators (&&, ||)
```bash
# && - Chạy lệnh sau NẾU lệnh trước THÀNH CÔNG
mkdir project && cd project
apt update && apt upgrade

# || - Chạy lệnh sau NẾU lệnh trước THẤT BẠI
cd /tmp || echo "Cannot access /tmp"
command || echo "Command failed"

# Kết hợp
mkdir backup && cp file.txt backup/ || echo "Backup failed"
```

### Xargs - Xử lý input thành arguments
```bash
# Tìm và xóa file
find . -name "*.tmp" | xargs rm

# Tìm và di chuyển
find . -name "*.log" | xargs -I {} mv {} logs/

# Với spaces trong filename
find . -name "*.txt" -print0 | xargs -0 rm

# Parallel execution
cat urls.txt | xargs -P 4 curl      # Download 4 URLs cùng lúc
```

### Thực hành Pipes
```bash
# Case 1: Tìm top 5 file lớn nhất
du -ah . | sort -rh | head -5

# Case 2: Count files by extension
find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn

# Case 3: Monitoring logs real-time
tail -f app.log | grep --line-buffered "ERROR"

# Case 4: Extract emails from file
cat file.txt | grep -Eo '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
```

---

## 7. Process Management (QUẢN LÝ TIẾN TRÌNH)

### Xem processes
```bash
# Danh sách processes
ps                  # Processes của user hiện tại
ps aux              # Tất cả processes (BSD style)
ps -ef              # Tất cả processes (UNIX style)
ps aux | grep nginx # Tìm process cụ thể

# Real-time monitoring
top                 # Xem real-time (q để thoát)
htop                # Top nhưng đẹp hơn (cần cài: sudo apt install htop)

# Tree view
pstree              # Xem process tree
pstree -p           # Hiển thị PID
```

### Kill processes
```bash
# Kill bằng PID
kill 1234           # Gửi SIGTERM (graceful)
kill -9 1234        # Gửi SIGKILL (force kill)
kill -15 1234       # SIGTERM (giống kill thường)

# Kill bằng tên
killall nginx       # Kill tất cả processes tên nginx
pkill -f "python script.py"     # Kill theo pattern

# Kiểm tra trước khi kill
pgrep nginx         # Tìm PID của nginx
pgrep -a nginx      # Hiển thị cả command line
```

### Background & Foreground jobs
```bash
# Chạy background (thêm & ở cuối)
./long_script.sh &
python server.py &

# Xem jobs đang chạy
jobs

# Đưa job lên foreground
fg                  # Job gần nhất
fg %1               # Job số 1

# Đưa job xuống background
bg %1               # Tiếp tục job 1 ở background

# Tạm dừng job hiện tại
Ctrl + Z            # Tạm dừng, sau đó dùng bg để tiếp tục ở background
```

### Nohup - Chạy khi logout
```bash
# Chạy process không bị kill khi logout
nohup ./script.sh &
nohup python server.py > output.log 2>&1 &

# Xem output
tail -f nohup.out
```

### Thực hành Process Management
```bash
# 1. Chạy process background
sleep 100 &
jobs

# 2. Tìm và kill
pgrep sleep
kill $(pgrep sleep)

# 3. Chạy server không sợ logout
nohup python3 -m http.server 8080 > server.log 2>&1 &

# 4. Kiểm tra port đang dùng
sudo lsof -i :8080
sudo netstat -tulpn | grep 8080
```

---

## 8. Environment Variables (BIẾN MÔI TRƯỜNG)

### Xem biến môi trường
```bash
# Liệt kê tất cả
env
printenv

# Xem biến cụ thể
echo $HOME
echo $PATH
echo $USER
echo $SHELL
```

### Set biến môi trường
```bash
# Biến tạm (chỉ trong session hiện tại)
MY_VAR="hello"
echo $MY_VAR

# Export - available cho child processes
export MY_VAR="hello"
export PATH=$PATH:/new/path

# Unset
unset MY_VAR
```

### Biến môi trường quan trọng
```bash
$HOME       # Thư mục home của user
$PATH       # Đường dẫn tìm kiếm commands
$USER       # Tên user hiện tại
$SHELL      # Shell đang dùng
$PWD        # Thư mục hiện tại
$OLDPWD     # Thư mục trước đó
```

### File cấu hình
```bash
# Bash
~/.bashrc       # Config cho interactive shell
~/.bash_profile # Config khi login
~/.profile      # Fallback nếu không có bash_profile

# Zsh (macOS mặc định)
~/.zshrc        # Config cho Zsh

# Edit và reload
vim ~/.bashrc
source ~/.bashrc        # Reload config
```

### Thực hành Environment Variables
```bash
# 1. Xem PATH hiện tại
echo $PATH

# 2. Thêm đường dẫn vào PATH (tạm thời)
export PATH=$PATH:$HOME/bin

# 3. Thêm vĩnh viễn (thêm vào ~/.bashrc hoặc ~/.zshrc)
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
source ~/.bashrc

# 4. Tạo alias trong .bashrc
echo "alias ll='ls -la'" >> ~/.bashrc
source ~/.bashrc
ll
```

---

## 9. Symbolic Links (LIÊN KẾT)

### Hard link vs Symbolic link
```bash
# Hard link - trỏ trực tiếp đến data
ln original.txt hardlink.txt

# Symbolic link (soft link) - giống shortcut
ln -s original.txt symlink.txt
ln -s /path/to/folder folder_link
```

### Sử dụng symbolic links
```bash
# Link file
ln -s /var/log/app.log ~/app.log
cat ~/app.log       # Đọc từ link

# Link folder
ln -s /var/www/html ~/www
cd ~/www            # Vào folder gốc

# Xem link trỏ đến đâu
ls -l symlink.txt
readlink symlink.txt

# Xóa link (KHÔNG xóa file gốc)
rm symlink.txt
unlink symlink.txt
```

### Use cases thực tế
```bash
# 1. Version management
ln -s /opt/python3.9/bin/python3 /usr/local/bin/python3
ln -s /opt/nodejs-v18/bin/node /usr/local/bin/node

# 2. Config files
ln -s ~/Dropbox/configs/.vimrc ~/.vimrc
ln -s ~/Dropbox/configs/.bashrc ~/.bashrc

# 3. Project shortcuts
ln -s /var/www/myproject ~/projects/myproject
```

---

## 10. Text Processing Tools (XỬ LÝ TEXT)

### Sort - Sắp xếp
```bash
# Sắp xếp cơ bản
sort file.txt
sort -r file.txt        # Reverse (Z-A)
sort -n file.txt        # Numeric sort
sort -u file.txt        # Unique (loại bỏ trùng)

# Sắp xếp theo cột
sort -k 2 file.txt      # Sắp xếp theo cột 2
sort -t ',' -k 2 file.csv   # Delimiter comma, cột 2
```

### Uniq - Loại bỏ trùng lặp
```bash
# Loại bỏ dòng trùng (phải sort trước!)
sort file.txt | uniq

# Đếm số lần xuất hiện
sort file.txt | uniq -c

# Chỉ hiển thị dòng trùng
sort file.txt | uniq -d

# Chỉ hiển thị dòng unique
sort file.txt | uniq -u
```

### Wc - Đếm
```bash
wc file.txt             # lines, words, bytes
wc -l file.txt          # Đếm lines
wc -w file.txt          # Đếm words
wc -c file.txt          # Đếm bytes
wc -m file.txt          # Đếm characters
```

### Cut - Cắt cột
```bash
# Cắt theo delimiter
cut -d ',' -f 1 file.csv        # Cột 1, delimiter comma
cut -d ':' -f 1,3 /etc/passwd   # Cột 1 và 3
cut -d ' ' -f 2- file.txt       # Từ cột 2 đến cuối

# Cắt theo vị trí ký tự
cut -c 1-10 file.txt            # Ký tự 1-10
```

### Tr - Transform characters
```bash
# Chuyển chữ hoa/thường
tr 'a-z' 'A-Z' < file.txt
cat file.txt | tr 'A-Z' 'a-z'

# Xóa ký tự
tr -d ',' < file.txt            # Xóa dấu phẩy
tr -d '\r' < windows.txt        # Xóa carriage return

# Thay thế
tr ' ' '_' < file.txt           # Thay space bằng underscore
```

### Thực hành Text Processing
```bash
# Tạo file test
cat > data.txt << EOF
apple,5,red
banana,3,yellow
apple,2,green
orange,4,orange
banana,1,yellow
EOF

# Case 1: Đếm số lượng mỗi loại fruit
cut -d ',' -f 1 data.txt | sort | uniq -c

# Case 2: Tổng số lượng (cột 2)
cut -d ',' -f 2 data.txt | paste -sd+ | bc

# Case 3: Unique colors
cut -d ',' -f 3 data.txt | sort -u

# Case 4: Log analysis
# Giả sử access.log có format: IP - - [date] "GET /path" status
cut -d ' ' -f 1 access.log | sort | uniq -c | sort -rn | head -10
# → Top 10 IPs có nhiều requests nhất
```

---

## 11. Các Lệnh Hệ Thống Hữu Ích

### Thông tin hệ thống
```bash
df -h               # Dung lượng ổ đĩa
du -sh folder/      # Kích thước thư mục
du -ah . | sort -rh | head -10  # Top 10 file/folder lớn nhất
free -h             # RAM
top                 # Tiến trình đang chạy (q để thoát)
htop                # Top nhưng đẹp hơn (cần cài)
ps aux              # Liệt kê tiến trình
uptime              # Thời gian chạy, load average
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
tar -czf archive.tar.gz folder/     # Nén (-c create, -z gzip, -f file)
tar -xzf archive.tar.gz             # Giải nén (-x extract)
tar -xzf archive.tar.gz -C /path/   # Giải nén vào folder khác
tar -tzf archive.tar.gz             # Xem nội dung (-t list)

# Tar.bz2 (nén tốt hơn nhưng chậm hơn)
tar -cjf archive.tar.bz2 folder/    # Nén (-j bzip2)
tar -xjf archive.tar.bz2            # Giải nén

# Zip
zip -r archive.zip folder/          # Nén
unzip archive.zip                   # Giải nén
unzip -l archive.zip                # Xem nội dung

# Gzip (chỉ file, không phải folder)
gzip file.txt                       # Tạo file.txt.gz
gunzip file.txt.gz                  # Giải nén
```

---

## 12. SSH & Remote Access (ENTERPRISE ESSENTIAL) 🔐

> **Critical!** 90% công việc enterprise là làm việc với remote servers. SSH là skill bắt buộc.

### SSH cơ bản
```bash
# Kết nối SSH
ssh username@hostname
ssh username@192.168.1.100
ssh -p 2222 user@host              # Custom port

# Thoát SSH session
exit
# hoặc Ctrl+D

# SSH với verbose (troubleshooting)
ssh -v user@host                   # Verbose
ssh -vv user@host                  # More verbose
ssh -vvv user@host                 # Maximum verbose
```

### SSH Keys - Authentication an toàn (NO PASSWORD!)

#### Tạo SSH key pair
```bash
# Tạo SSH key (recommended: ED25519)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Hoặc RSA (legacy compatibility)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Key sẽ được lưu tại:
# Private key: ~/.ssh/id_ed25519 (KHÔNG share!)
# Public key: ~/.ssh/id_ed25519.pub (share được)

# Set permissions đúng (QUAN TRỌNG!)
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

#### Copy public key lên server
```bash
# Cách 1: Dùng ssh-copy-id (dễ nhất)
ssh-copy-id user@server

# Cách 2: Manual
cat ~/.ssh/id_ed25519.pub | ssh user@server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Cách 3: Copy paste thủ công
cat ~/.ssh/id_ed25519.pub
# Copy output, SSH vào server, paste vào ~/.ssh/authorized_keys
```

#### Kiểm tra SSH key login
```bash
# Login không cần password
ssh user@server

# Nếu vẫn hỏi password → check permissions
ls -la ~/.ssh/                     # Local
ssh user@server "ls -la ~/.ssh/"   # Remote
```

### SSH Config - Quản lý nhiều servers

#### ~/.ssh/config
```bash
# Edit config
vim ~/.ssh/config

# Example config
Host production
    HostName 192.168.1.100
    User deploy
    Port 22
    IdentityFile ~/.ssh/id_production

Host staging
    HostName staging.example.com
    User ubuntu
    Port 2222
    IdentityFile ~/.ssh/id_staging

Host *.example.com
    User admin
    IdentityFile ~/.ssh/id_company

# Bây giờ connect đơn giản:
ssh production
ssh staging
```

#### Config options hữu ích
```bash
Host *
    # Keep connection alive
    ServerAliveInterval 60
    ServerAliveCountMax 3
    
    # Reuse connections (faster)
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
    
    # Jump host
    ProxyJump bastion.example.com
```

### SCP - Copy files qua SSH

```bash
# Copy file từ local → remote
scp file.txt user@server:/path/to/destination/

# Copy file từ remote → local
scp user@server:/path/to/file.txt ./

# Copy folder (recursive)
scp -r folder/ user@server:/path/to/destination/

# Copy với custom port
scp -P 2222 file.txt user@server:/path/

# Copy nhiều files
scp file1.txt file2.txt user@server:/path/

# Copy với compression (faster cho large files)
scp -C largefile.zip user@server:/path/
```

### Rsync - Sync files (Better than SCP!)

```bash
# Sync folder (dry run trước)
rsync -avzn local/ user@server:/remote/
# -a: archive mode
# -v: verbose
# -z: compression
# -n: dry run (test)

# Real sync (bỏ -n)
rsync -avz local/ user@server:/remote/

# Sync với progress
rsync -avz --progress large_folder/ user@server:/backup/

# Sync và xóa files không còn ở source
rsync -avz --delete local/ user@server:/remote/

# Exclude files
rsync -avz --exclude '*.log' --exclude 'node_modules' \
  project/ user@server:/var/www/

# Backup incremental
rsync -avz --backup --backup-dir=/backup/$(date +%Y%m%d) \
  /data/ user@server:/backup/latest/
```

### SSH Tunneling & Port Forwarding

#### Local Port Forwarding
```bash
# Forward local port → remote service
ssh -L 8080:localhost:80 user@server
# Giờ truy cập localhost:8080 = server:80

# Access remote database locally
ssh -L 5432:localhost:5432 user@dbserver
# Connect to localhost:5432 = dbserver PostgreSQL

# Keep alive in background
ssh -fN -L 8080:localhost:80 user@server
```

#### Remote Port Forwarding
```bash
# Expose local service to remote
ssh -R 8080:localhost:3000 user@server
# server:8080 → your_machine:3000

# Useful cho demo/testing
ssh -R 80:localhost:8000 serveo.net
```

#### Dynamic Port Forwarding (SOCKS Proxy)
```bash
# Create SOCKS proxy
ssh -D 1080 user@server

# Configure browser to use SOCKS proxy localhost:1080
# → All traffic routed through server
```

### SSH Agent - Quản lý keys

```bash
# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# List loaded keys
ssh-add -l

# Remove all keys
ssh-add -D

# Forward agent (use local keys on remote)
ssh -A user@server
```

### Thực hành SSH - Enterprise Scenarios

#### Scenario 1: Setup passwordless login
```bash
# 1. Generate key
ssh-keygen -t ed25519 -C "myname@company.com"

# 2. Copy to server
ssh-copy-id user@production-server

# 3. Test
ssh user@production-server

# 4. Disable password login (on server)
sudo vim /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart sshd
```

#### Scenario 2: Jump through bastion host
```bash
# Direct (not recommended)
ssh -J bastion.com private-server

# Better: Config
vim ~/.ssh/config
Host private
    HostName 10.0.0.10
    User admin
    ProxyJump bastion.com

# Now just:
ssh private
```

#### Scenario 3: Backup remote server
```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
rsync -avz --delete \
  user@server:/var/www/ \
  /backup/www_$DATE/

# Check backup
echo "Backup completed: $(date)" >> /var/log/backup.log
```

#### Scenario 4: Deploy code to production
```bash
# Deploy script
#!/bin/bash
echo "Deploying to production..."

# Sync code
rsync -avz --exclude '.git' --exclude 'node_modules' \
  ./ user@production:/var/www/app/

# Restart service
ssh user@production "cd /var/www/app && \
  npm install && \
  pm2 restart app"

echo "Deploy completed!"
```

### Security Best Practices

```bash
# ✅ DO
- Dùng SSH keys, không dùng passwords
- Set permissions đúng (700 ~/.ssh, 600 private keys)
- Dùng strong passphrases cho keys
- Different keys cho different environments
- Keep private keys PRIVATE (never commit to git!)
- Use SSH config để organize

# ❌ DON'T
- Share private keys
- Use same key everywhere
- Commit keys to version control
- Login as root (use sudo)
- Allow password authentication in production
- Use default ports (change from 22)
```

### Troubleshooting SSH

```bash
# Problem: Permission denied
# Solution: Check permissions
ls -la ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519

# Problem: Host key verification failed
# Solution: Remove old key
ssh-keygen -R hostname

# Problem: Connection refused
# Solution: Check server sshd status
ssh user@server "systemctl status sshd"

# Problem: Too many authentication failures
# Solution: Specify key explicitly
ssh -i ~/.ssh/specific_key user@server

# Debug connection
ssh -vvv user@server 2>&1 | grep -i error
```

---

## 13. Cron Jobs & Task Scheduling (AUTOMATION) ⏰

> **Enterprise Need**: Automate backups, cleanup, monitoring, reports - chạy tự động không cần người.

### Cron Basics

```bash
# Xem cron jobs của user hiện tại
crontab -l

# Edit cron jobs
crontab -e

# Xóa tất cả cron jobs
crontab -r

# Xem cron của user khác (as root)
sudo crontab -u username -l
```

### Cron Syntax - 5 Fields

```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, 0=Sunday)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)

Special characters:
* = any value
, = list (1,3,5)
- = range (1-5)
/ = step (*/5 = every 5)
```

### Cron Examples - Common Patterns

```bash
# Mỗi phút
* * * * * /path/to/script.sh

# Mỗi 5 phút
*/5 * * * * /path/to/script.sh

# Mỗi giờ (phút 0)
0 * * * * /path/to/script.sh

# Mỗi ngày 2:30 AM
30 2 * * * /path/to/backup.sh

# Mỗi Chủ nhật 3:00 AM
0 3 * * 0 /path/to/weekly-task.sh

# Ngày đầu mỗi tháng
0 0 1 * * /path/to/monthly-report.sh

# Thứ 2-6 (working days) 9:00 AM
0 9 * * 1-5 /path/to/workday-task.sh

# Mỗi 6 giờ
0 */6 * * * /path/to/script.sh

# Mỗi 15 phút trong giờ làm việc
*/15 9-17 * * 1-5 /path/to/check.sh
```

### Cron Special Strings

```bash
# @reboot - Chạy khi boot
@reboot /path/to/startup.sh

# @daily (= 0 0 * * *)
@daily /path/to/daily-backup.sh

# @hourly (= 0 * * * *)
@hourly /path/to/hourly-check.sh

# @weekly (= 0 0 * * 0)
@weekly /path/to/weekly-cleanup.sh

# @monthly (= 0 0 1 * *)
@monthly /path/to/monthly-report.sh

# @yearly (= 0 0 1 1 *)
@yearly /path/to/annual-task.sh
```

### Cron Best Practices

#### 1. Absolute paths
```bash
# ❌ BAD - Relative paths
*/5 * * * * backup.sh

# ✅ GOOD - Absolute paths
*/5 * * * * /home/user/scripts/backup.sh
```

#### 2. Redirect output & errors
```bash
# Save to log file
*/5 * * * * /path/to/script.sh >> /var/log/myscript.log 2>&1

# Send errors only
*/5 * * * * /path/to/script.sh 2>> /var/log/errors.log

# Discard output
*/5 * * * * /path/to/script.sh > /dev/null 2>&1
```

#### 3. Set environment variables
```bash
# At top of crontab
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=admin@example.com

# Jobs
0 2 * * * /path/to/backup.sh
```

#### 4. Lock files (prevent overlap)
```bash
#!/bin/bash
LOCKFILE=/var/lock/myscript.lock

if [ -e $LOCKFILE ]; then
    echo "Script already running"
    exit 1
fi

touch $LOCKFILE
trap "rm -f $LOCKFILE" EXIT

# Your script here
echo "Running task..."
sleep 60

# Lock removed by trap
```

### Enterprise Cron Examples

#### Example 1: Daily Database Backup
```bash
# crontab
0 2 * * * /home/admin/scripts/db-backup.sh

# /home/admin/scripts/db-backup.sh
#!/bin/bash
DATE=$(date +%Y%m%d)
BACKUP_DIR=/backup/db

# Backup
pg_dump mydb > $BACKUP_DIR/mydb_$DATE.sql
gzip $BACKUP_DIR/mydb_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Backup completed: $(date)" >> /var/log/db-backup.log
```

#### Example 2: Log Cleanup
```bash
# crontab - daily 3 AM
0 3 * * * /home/admin/scripts/cleanup-logs.sh

# cleanup-logs.sh
#!/bin/bash
# Delete logs older than 30 days
find /var/log/app -name "*.log" -mtime +30 -delete

# Compress logs older than 7 days
find /var/log/app -name "*.log" -mtime +7 -exec gzip {} \;

echo "Cleanup completed: $(date)" >> /var/log/cleanup.log
```

#### Example 3: Disk Space Monitoring
```bash
# crontab - every hour
0 * * * * /home/admin/scripts/check-disk.sh

# check-disk.sh
#!/bin/bash
THRESHOLD=80
EMAIL="admin@example.com"

USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ $USAGE -gt $THRESHOLD ]; then
    echo "ALERT: Disk usage is ${USAGE}%" | \
    mail -s "Disk Space Alert" $EMAIL
fi
```

#### Example 4: SSL Certificate Check
```bash
# crontab - daily check
0 8 * * * /home/admin/scripts/check-cert.sh

# check-cert.sh
#!/bin/bash
DOMAIN="example.com"
DAYS_WARNING=30

EXPIRY=$(echo | openssl s_client -servername $DOMAIN \
  -connect $DOMAIN:443 2>/dev/null | \
  openssl x509 -noout -enddate | cut -d= -f2)

EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt $DAYS_WARNING ]; then
    echo "SSL cert expires in $DAYS_LEFT days!" | \
    mail -s "SSL Certificate Warning" admin@example.com
fi
```

### System-wide Cron Directories

```bash
# System cron directories
/etc/cron.d/          # Drop cron files here
/etc/cron.daily/      # Scripts chạy daily
/etc/cron.hourly/     # Scripts chạy hourly
/etc/cron.weekly/     # Scripts chạy weekly
/etc/cron.monthly/    # Scripts chạy monthly

# Add script to daily cron
sudo cp script.sh /etc/cron.daily/
sudo chmod +x /etc/cron.daily/script.sh
```

### Cron Logging & Debugging

```bash
# Xem cron logs
grep CRON /var/log/syslog
tail -f /var/log/syslog | grep CRON

# Test cron job manually
/path/to/script.sh

# Add logging to script
echo "$(date): Script started" >> /var/log/myscript.log
# ... your code ...
echo "$(date): Script completed" >> /var/log/myscript.log

# Verify cron is running
systemctl status cron
# or
service cron status
```

### At Command - One-time Scheduling

```bash
# Schedule one-time task
echo "/path/to/script.sh" | at 14:30
echo "backup.sh" | at now + 1 hour
echo "cleanup.sh" | at 23:00 tomorrow

# List scheduled jobs
atq

# Remove job
atrm <job_number>

# View job details
at -c <job_number>
```

### Systemd Timers (Modern Alternative)

```bash
# systemd timer example
# /etc/systemd/system/backup.timer
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target

# /etc/systemd/system/backup.service
[Unit]
Description=Backup Service

[Service]
Type=oneshot
ExecStart=/home/admin/scripts/backup.sh

# Enable timer
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# Check status
sudo systemctl list-timers
```

---

## 14. System Services Management (systemd) 🔧

> **Production Critical**: Manage applications, databases, web servers - systemd quản lý TẤT CẢ services.

### Systemctl Basics

```bash
# Xem status của service
systemctl status nginx
systemctl status postgresql
systemctl status ssh

# Start service
sudo systemctl start nginx

# Stop service
sudo systemctl stop nginx

# Restart service
sudo systemctl restart nginx

# Reload config (không restart)
sudo systemctl reload nginx

# Enable service (start on boot)
sudo systemctl enable nginx

# Disable service (don't start on boot)
sudo systemctl disable nginx

# Enable và start cùng lúc
sudo systemctl enable --now nginx
```

### Kiểm tra Services

```bash
# List tất cả services
systemctl list-units --type=service

# List active services
systemctl list-units --type=service --state=active

# List failed services
systemctl list-units --type=service --state=failed

# List enabled services (auto-start)
systemctl list-unit-files --type=service --state=enabled

# Check nếu service enabled
systemctl is-enabled nginx

# Check nếu service running
systemctl is-active nginx

# Show service dependencies
systemctl list-dependencies nginx
```

### Journalctl - View Logs

```bash
# Xem tất cả logs
journalctl

# Xem logs của service cụ thể
journalctl -u nginx
journalctl -u postgresql

# Follow logs real-time
journalctl -u nginx -f

# Logs since boot
journalctl -b

# Logs từ today
journalctl --since today

# Logs trong khoảng thời gian
journalctl --since "2024-01-01" --until "2024-01-31"
journalctl --since "1 hour ago"
journalctl --since "10 minutes ago"

# Last 100 lines
journalctl -u nginx -n 100

# Reverse order (newest first)
journalctl -u nginx -r

# Show only errors
journalctl -u nginx -p err

# Priority levels: emerg, alert, crit, err, warning, notice, info, debug
journalctl -p warning

# Disk usage của logs
journalctl --disk-usage

# Clean old logs
sudo journalctl --vacuum-time=7d    # Keep last 7 days
sudo journalctl --vacuum-size=1G    # Keep max 1GB
```

### Tạo Custom Service File

#### Simple Service Example
```bash
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/var/www/myapp
ExecStart=/usr/bin/node /var/www/myapp/server.js
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

#### Web Application Service
```bash
# /etc/systemd/system/webapp.service
[Unit]
Description=Web Application
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/app
Environment="NODE_ENV=production"
Environment="PORT=3000"
ExecStart=/usr/bin/npm start
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10
StandardOutput=append:/var/log/webapp/output.log
StandardError=append:/var/log/webapp/error.log

[Install]
WantedBy=multi-user.target
```

#### Python Application
```bash
# /etc/systemd/system/pyapp.service
[Unit]
Description=Python Application
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/pyapp
Environment="PATH=/opt/pyapp/venv/bin"
ExecStart=/opt/pyapp/venv/bin/python /opt/pyapp/app.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Service File Sections

#### [Unit] Section
```ini
Description=Service description
Documentation=https://docs.example.com
After=network.target                # Start after
Before=other.service                # Start before
Requires=postgresql.service         # Hard dependency
Wants=redis.service                 # Soft dependency
```

#### [Service] Section
```ini
Type=simple         # Default, process runs in foreground
Type=forking        # Process forks (traditional daemons)
Type=oneshot        # Runs once and exits
Type=notify         # Notifies systemd when ready

User=username       # Run as this user
Group=groupname     # Run as this group
WorkingDirectory=/path

ExecStart=/path/to/command          # Start command
ExecStop=/path/to/stop-command      # Stop command (optional)
ExecReload=/path/to/reload          # Reload command (optional)

Restart=always              # Always restart
Restart=on-failure          # Restart only on failure
Restart=no                  # Never restart
RestartSec=10               # Wait before restart

Environment="VAR=value"     # Set environment variables
EnvironmentFile=/etc/myapp/config   # Load env from file
```

#### [Install] Section
```ini
WantedBy=multi-user.target      # Standard for services
WantedBy=graphical.target       # For GUI apps
```

### Activate Custom Service

```bash
# 1. Create service file
sudo vim /etc/systemd/system/myapp.service

# 2. Reload systemd
sudo systemctl daemon-reload

# 3. Enable service
sudo systemctl enable myapp

# 4. Start service
sudo systemctl start myapp

# 5. Check status
sudo systemctl status myapp

# 6. View logs
sudo journalctl -u myapp -f
```

### Enterprise Service Management Examples

#### Example 1: Node.js Application
```bash
# /etc/systemd/system/nodejs-app.service
[Unit]
Description=Node.js API Server
After=network.target

[Service]
Type=simple
User=nodejs
Group=nodejs
WorkingDirectory=/var/www/api
Environment="NODE_ENV=production"
Environment="PORT=3000"
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
StandardOutput=append:/var/log/nodejs-app/output.log
StandardError=append:/var/log/nodejs-app/error.log

# Security
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target

# Deploy
sudo systemctl daemon-reload
sudo systemctl enable --now nodejs-app
sudo journalctl -u nodejs-app -f
```

#### Example 2: Database Backup Service
```bash
# /etc/systemd/system/db-backup.service
[Unit]
Description=Database Backup Service

[Service]
Type=oneshot
User=backup
ExecStart=/home/backup/scripts/backup-db.sh
StandardOutput=append:/var/log/backup/output.log
StandardError=append:/var/log/backup/error.log

# /etc/systemd/system/db-backup.timer
[Unit]
Description=Daily Database Backup

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target

# Enable timer
sudo systemctl enable --now db-backup.timer
sudo systemctl list-timers
```

#### Example 3: Monitoring Script
```bash
# /etc/systemd/system/monitor.service
[Unit]
Description=System Monitoring
After=network.target

[Service]
Type=simple
User=monitor
ExecStart=/usr/bin/python3 /opt/monitor/monitor.py
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
```

### Common Services Commands

```bash
# Web Servers
sudo systemctl restart nginx
sudo systemctl reload apache2

# Databases
sudo systemctl start postgresql
sudo systemctl status mysql

# SSH
sudo systemctl restart sshd

# Cron
sudo systemctl restart cron

# Docker
sudo systemctl start docker
```

### Troubleshooting Services

```bash
# Service won't start
systemctl status myapp              # Check status
journalctl -u myapp -n 50           # Last 50 log lines
journalctl -u myapp --since "5 minutes ago"

# Check syntax
sudo systemd-analyze verify /etc/systemd/system/myapp.service

# Reload config after changes
sudo systemctl daemon-reload
sudo systemctl restart myapp

# Failed to start
journalctl -xe                      # Extended info
systemctl list-dependencies myapp   # Check dependencies

# Permission issues
sudo journalctl -u myapp | grep -i permission
# Check User/Group in service file
# Check file permissions in WorkingDirectory
```

### Service Best Practices

```bash
# ✅ DO
- Use systemd for production services
- Set Restart=always or on-failure
- Log to dedicated files
- Set appropriate User/Group (not root!)
- Use After= để đảm bảo dependencies
- Test service file syntax
- Monitor logs với journalctl

# ❌ DON'T
- Run services as root (unless required)
- Ignore failed services (check systemctl --failed)
- Forget to daemon-reload after changes
- Use Type=simple for forking processes
- Leave debug logs in production
```

---

## 15. Package Management (SOFTWARE INSTALL) 📦

> **Essential**: Install, update, remove software - mỗi Linux distro có package manager riêng.

### APT (Ubuntu/Debian)

#### Basic Commands
```bash
# Update package list
sudo apt update

# Upgrade all packages
sudo apt upgrade

# Full upgrade (install/remove if needed)
sudo apt full-upgrade

# Install package
sudo apt install nginx
sudo apt install postgresql python3-pip

# Remove package
sudo apt remove nginx

# Remove package + config files
sudo apt purge nginx

# Remove unused dependencies
sudo apt autoremove

# Search package
apt search nginx
apt search "web server"

# Show package info
apt show nginx

# List installed packages
apt list --installed
apt list --installed | grep nginx
```

#### Advanced APT
```bash
# Install specific version
sudo apt install nginx=1.18.0-0ubuntu1

# Hold package (prevent upgrade)
sudo apt-mark hold nginx
sudo apt-mark unhold nginx

# Download package without installing
apt download nginx

# Reinstall package
sudo apt reinstall nginx

# Check for broken dependencies
sudo apt --fix-broken install

# Clean cache
sudo apt clean
sudo apt autoclean
```

### YUM/DNF (RHEL/CentOS/Fedora)

```bash
# DNF (Fedora 22+, RHEL 8+)
sudo dnf update                     # Update packages
sudo dnf install nginx              # Install
sudo dnf remove nginx               # Remove
sudo dnf search nginx               # Search
sudo dnf info nginx                 # Info
sudo dnf list installed             # List installed

# YUM (Older RHEL/CentOS)
sudo yum update
sudo yum install nginx
sudo yum remove nginx
sudo yum search nginx
sudo yum clean all                  # Clean cache
```

### Enterprise Package Management

#### Example 1: Setup Web Stack (LEMP)
```bash
#!/bin/bash
# Install LEMP Stack (Linux, Nginx, MySQL, PHP)

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing Nginx..."
sudo apt install -y nginx
sudo systemctl enable --now nginx

echo "Installing MySQL..."
sudo apt install -y mysql-server
sudo systemctl enable --now mysql
sudo mysql_secure_installation

echo "Installing PHP..."
sudo apt install -y php-fpm php-mysql php-cli php-curl php-xml

echo "Verifying installation..."
nginx -v
mysql --version
php -v

echo "LEMP stack installed!"
```

#### Example 2: Install Development Tools
```bash
# Development tools
sudo apt install -y \
  build-essential \
  git \
  curl \
  wget \
  vim \
  htop \
  net-tools \
  software-properties-common

# Python development
sudo apt install -y \
  python3 \
  python3-pip \
  python3-venv

# Node.js (from NodeSource)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
```

#### Example 3: Security Updates Only
```bash
# Install unattended-upgrades
sudo apt install -y unattended-upgrades

# Configure
sudo dpkg-reconfigure -plow unattended-upgrades

# Manual security updates
sudo apt update
sudo apt list --upgradable
sudo apt upgrade -y
```

### Adding Third-party Repositories

#### Add PPA (Ubuntu)
```bash
# Add repository
sudo add-apt-repository ppa:nginx/stable
sudo apt update

# Remove repository
sudo add-apt-repository --remove ppa:nginx/stable
```

#### Add GPG Key & Repository (Manual)
```bash
# Example: PostgreSQL official repo
# 1. Add GPG key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -

# 2. Add repository
echo "deb http://apt.postgresql.org/pub/repos/apt/ \
  $(lsb_release -cs)-pgdg main" | \
  sudo tee /etc/apt/sources.list.d/pgdg.list

# 3. Update and install
sudo apt update
sudo apt install -y postgresql-14
```

### Package Query & Information

```bash
# Which package provides a file?
dpkg -S /usr/bin/vim
apt-file search /usr/bin/vim

# List files in package
dpkg -L nginx

# Show package dependencies
apt depends nginx

# Show reverse dependencies (what depends on this)
apt rdepends nginx

# Verify installed packages
sudo dpkg --verify

# Check if package installed
dpkg -l | grep nginx
```

### Troubleshooting Package Issues

```bash
# Problem: Broken packages
sudo apt --fix-broken install
sudo dpkg --configure -a

# Problem: Lock file exists
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*
sudo dpkg --configure -a

# Problem: Hash sum mismatch
sudo rm -rf /var/lib/apt/lists/*
sudo apt clean
sudo apt update

# Problem: Held broken packages
sudo apt autoremove
sudo apt --fix-broken install
```

### Best Practices

```bash
# ✅ DO
- apt update before apt install
- Use apt instead of apt-get (modern)
- Regular security updates
- Test updates on staging first
- Keep system packages minimal
- Document installed packages
- Use version pinning for critical apps

# ❌ DON'T
- Skip apt update
- Mix package managers (apt + snap + flatpak)
- Install random PPAs without verification
- Hold packages unnecessarily
- Ignore broken dependencies
```

---

## 16. Log Management & Analysis (TROUBLESHOOTING) 📝

> **Debug Critical**: Logs = eyes into your system. No logs = blind troubleshooting.

### Important Log Files

```bash
# System Logs
/var/log/syslog                 # Ubuntu/Debian general log
/var/log/messages               # RHEL/CentOS general log
/var/log/dmesg                  # Kernel ring buffer
/var/log/boot.log               # Boot messages

# Authentication
/var/log/auth.log               # Ubuntu/Debian authentication
/var/log/secure                 # RHEL/CentOS authentication

# Services
/var/log/nginx/access.log       # Nginx access
/var/log/nginx/error.log        # Nginx errors
/var/log/apache2/access.log     # Apache access
/var/log/mysql/error.log        # MySQL errors
/var/log/postgresql/            # PostgreSQL logs

# Applications
/var/log/application/           # Custom app logs
~/app.log                       # User space logs
```

### Viewing Logs - Basic Commands

```bash
# View log file
cat /var/log/syslog
less /var/log/syslog                    # Paginated
tail /var/log/syslog                    # Last 10 lines
tail -n 50 /var/log/syslog              # Last 50 lines

# Follow log real-time
tail -f /var/log/syslog
tail -f /var/log/nginx/access.log

# Multiple files
tail -f /var/log/nginx/*.log

# With timestamps
tail -f /var/log/syslog | while read line; do 
  echo "$(date '+%Y-%m-%d %H:%M:%S') $line"
done
```

### Journalctl - Systemd Logs (Modern Way)

```bash
# All logs
journalctl

# Logs for specific service
journalctl -u nginx
journalctl -u postgresql

# Follow logs
journalctl -u nginx -f

# Last N lines
journalctl -u nginx -n 100

# Since time
journalctl --since "2024-01-14 10:00"
journalctl --since "1 hour ago"
journalctl --since today
journalctl --since yesterday

# Time range
journalctl --since "2024-01-14" --until "2024-01-15"

# Priority levels
journalctl -p err                       # Errors only
journalctl -p warning                   # Warning and above
# Levels: emerg(0), alert(1), crit(2), err(3), warning(4), notice(5), info(6), debug(7)

# Kernel messages
journalctl -k
journalctl -k -b                        # Current boot

# Boot logs
journalctl -b                           # Current boot
journalctl -b -1                        # Previous boot
journalctl --list-boots                 # List all boots

# Output format
journalctl -o json                      # JSON format
journalctl -o json-pretty               # Pretty JSON
journalctl -o verbose                   # Verbose

# Export logs
journalctl -u nginx --since today > nginx_today.log
```

### Log Analysis - Find Issues

#### Search for errors
```bash
# Grep for errors
grep -i error /var/log/syslog
grep -i "failed\|error\|critical" /var/log/syslog

# With context
grep -C 5 -i error /var/log/nginx/error.log

# Multiple files
grep -r "error" /var/log/nginx/

# Journalctl search
journalctl -u nginx | grep -i error
journalctl -p err                       # Errors only
```

#### Count occurrences
```bash
# Count errors
grep -c "error" /var/log/syslog

# Count by type
grep "error" /var/log/syslog | sort | uniq -c | sort -rn

# Top 10 errors
grep "error" /var/log/nginx/error.log | \
  cut -d' ' -f10- | sort | uniq -c | sort -rn | head -10
```

#### Analyze access logs
```bash
# Top 10 IPs
cat /var/log/nginx/access.log | \
  awk '{print $1}' | sort | uniq -c | sort -rn | head -10

# Top 10 URLs
cat /var/log/nginx/access.log | \
  awk '{print $7}' | sort | uniq -c | sort -rn | head -10

# 404 errors
grep " 404 " /var/log/nginx/access.log | \
  awk '{print $7}' | sort | uniq -c | sort -rn

# 5xx errors
grep " 5[0-9][0-9] " /var/log/nginx/access.log

# Requests per hour
cat /var/log/nginx/access.log | \
  cut -d[ -f2 | cut -d] -f1 | \
  awk -F: '{print $2":00"}' | sort -n | uniq -c
```

### Log Rotation (logrotate)

```bash
# Config file
/etc/logrotate.conf

# Service-specific configs
/etc/logrotate.d/nginx
/etc/logrotate.d/apache2

# Example config
# /etc/logrotate.d/myapp
/var/log/myapp/*.log {
    daily                   # Rotate daily
    missingok              # Don't error if log missing
    rotate 14              # Keep 14 days
    compress               # Compress old logs
    delaycompress          # Compress previous log on next rotation
    notifempty             # Don't rotate if empty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        systemctl reload nginx > /dev/null
    endscript
}

# Test configuration
sudo logrotate -d /etc/logrotate.d/myapp

# Force rotation
sudo logrotate -f /etc/logrotate.d/myapp
```

### Enterprise Log Management Examples

#### Example 1: Monitor Failed Login Attempts
```bash
#!/bin/bash
# monitor-logins.sh
THRESHOLD=5
LOGFILE=/var/log/auth.log
EMAIL="admin@example.com"

# Count failed attempts in last hour
FAILED=$(grep "Failed password" $LOGFILE | \
  grep "$(date '+%b %e %H')" | wc -l)

if [ $FAILED -gt $THRESHOLD ]; then
    echo "WARNING: $FAILED failed login attempts in last hour" | \
    mail -s "Security Alert" $EMAIL
fi

# Run every hour via cron
# 0 * * * * /home/admin/scripts/monitor-logins.sh
```

#### Example 2: Application Error Alerting
```bash
#!/bin/bash
# check-app-errors.sh
APP_LOG=/var/log/myapp/app.log
ERROR_COUNT=$(tail -1000 $APP_LOG | grep -c "ERROR")

if [ $ERROR_COUNT -gt 10 ]; then
    echo "Application has $ERROR_COUNT errors in last 1000 lines" | \
    mail -s "App Error Alert" admin@example.com
    
    # Send last 50 errors
    tail -1000 $APP_LOG | grep "ERROR" | tail -50 | \
    mail -s "Recent Errors" admin@example.com
fi
```

#### Example 3: Disk Space from Logs
```bash
#!/bin/bash
# cleanup-logs.sh
LOG_DIR=/var/log/app

# Archive logs older than 7 days
find $LOG_DIR -name "*.log" -mtime +7 -exec gzip {} \;

# Delete archived logs older than 30 days
find $LOG_DIR -name "*.log.gz" -mtime +30 -delete

# Alert if log directory > 5GB
SIZE=$(du -sm $LOG_DIR | awk '{print $1}')
if [ $SIZE -gt 5000 ]; then
    echo "Log directory is ${SIZE}MB" | \
    mail -s "Log Space Warning" admin@example.com
fi
```

#### Example 4: Web Server Access Analysis
```bash
# Daily traffic report
#!/bin/bash
DATE=$(date -d yesterday '+%Y-%m-%d')
LOG=/var/log/nginx/access.log

echo "Traffic Report for $DATE" > /tmp/report.txt
echo "=========================" >> /tmp/report.txt

echo -e "\nTotal Requests:" >> /tmp/report.txt
grep "$DATE" $LOG | wc -l >> /tmp/report.txt

echo -e "\nTop 10 IPs:" >> /tmp/report.txt
grep "$DATE" $LOG | awk '{print $1}' | \
  sort | uniq -c | sort -rn | head -10 >> /tmp/report.txt

echo -e "\nTop 10 URLs:" >> /tmp/report.txt
grep "$DATE" $LOG | awk '{print $7}' | \
  sort | uniq -c | sort -rn | head -10 >> /tmp/report.txt

echo -e "\nHTTP Status Codes:" >> /tmp/report.txt
grep "$DATE" $LOG | awk '{print $9}' | \
  sort | uniq -c | sort -rn >> /tmp/report.txt

# Email report
cat /tmp/report.txt | mail -s "Daily Traffic Report" admin@example.com
```

### Centralized Logging (Enterprise)

```bash
# Syslog forwarding (to central log server)
# /etc/rsyslog.d/50-default.conf
*.* @@logserver.example.com:514      # TCP
*.* @logserver.example.com:514       # UDP

# Restart rsyslog
sudo systemctl restart rsyslog

# Test
logger "Test message from $(hostname)"
```

### Best Practices

```bash
# ✅ DO
- Configure log rotation
- Monitor logs proactively
- Aggregate logs centrally (ELK, Splunk, etc.)
- Set up alerts for critical errors
- Keep logs for compliance (30-90 days minimum)
- Use structured logging (JSON)
- Include timestamps and log levels
- Separate access and error logs

# ❌ DON'T
- Log sensitive data (passwords, tokens, PII)
- Let logs fill up disk
- Ignore permission issues on log files
- Run services with excessive debug logging in production
- Delete logs without archiving
```

### Troubleshooting with Logs - Workflow

```bash
# 1. Identify the problem
# User reports: "Website down"

# 2. Check service status
sudo systemctl status nginx

# 3. Check recent logs
sudo journalctl -u nginx -n 100

# 4. Check error logs
sudo tail -50 /var/log/nginx/error.log

# 5. Check system logs
sudo journalctl -p err --since "10 minutes ago"

# 6. Check resource usage
df -h                                   # Disk space
free -h                                 # Memory
top                                     # CPU/Memory

# 7. Check network
sudo netstat -tulpn | grep :80         # Port listening?

# 8. Fix and verify
sudo systemctl restart nginx
sudo journalctl -u nginx -f            # Watch for errors
```

---

## 17. Common Mistakes & Tips (SAI LẦM THƯỜNG GẶP)

### ❌ Sai lầm 1: rm -rf / (NGUY HIỂM!)
```bash
# ĐỪNG BAO GIỜ chạy:
rm -rf /                # XÓA TOÀN BỘ HỆ THỐNG!
rm -rf /*               # Tương tự!

# Luôn CHECK kỹ đường dẫn trước khi rm -rf
pwd
ls
# Rồi mới rm -rf folder_name
```

### ❌ Sai lầm 2: Quên dùng quotes với spaces
```bash
# SAI
cd My Documents         # Error!
rm My File.txt          # Error!

# ĐÚNG
cd "My Documents"
rm "My File.txt"
cd My\ Documents        # Hoặc dùng backslash
```

### ❌ Sai lầm 3: > vs >>
```bash
# > GHI ĐÈ (mất data cũ!)
echo "new" > file.txt

# >> GHI THÊM (giữ data cũ)
echo "add" >> file.txt
```

### ❌ Sai lầm 4: Không check exit code
```bash
# SAI
command
# Không biết thành công hay fail

# ĐÚNG
command
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi

# Hoặc dùng &&
command && echo "Success" || echo "Failed"
```

### ✅ Best Practices
```bash
# 1. Luôn backup trước khi xóa/sửa
cp important.txt important.txt.backup
rm important.txt

# 2. Dùng -i để confirm
rm -i file.txt
mv -i old.txt new.txt

# 3. Test command trước
ls folder/              # Xem có gì
rm -r folder/           # Rồi mới xóa

# 4. Dùng tab completion
cd Doc[TAB]             # Tự động hoàn thành
rm file[TAB]

# 5. Check manual khi không chắc
man command
command --help
```

---

## 13. One-Liners Hữu Ích (COPY & USE)

### File & Directory
```bash
# Tìm 10 file lớn nhất
find . -type f -exec du -h {} + | sort -rh | head -10

# Tìm file theo kích thước
find . -type f -size +100M          # File > 100MB
find . -type f -size -1M            # File < 1MB

# Tìm file modified trong 7 ngày
find . -type f -mtime -7

# Xóa file cũ hơn 30 ngày
find . -type f -mtime +30 -delete

# Count files trong folder
find . -type f | wc -l
```

### Text Processing
```bash
# Replace text trong nhiều files
find . -name "*.txt" -exec sed -i 's/old/new/g' {} \;

# Tìm duplicate files
find . -type f -exec md5sum {} + | sort | uniq -w32 -D

# Extract emails từ text
grep -Eo '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt

# Count occurrences
grep -o "word" file.txt | wc -l
```

### System Monitoring
```bash
# Monitor disk usage real-time
watch -n 1 df -h

# Monitor log file
tail -f /var/log/syslog | grep --line-buffered "error"

# Top memory consuming processes
ps aux | sort -k 4 -rn | head -10

# Top CPU consuming processes
ps aux | sort -k 3 -rn | head -10

# Check port usage
sudo lsof -i :80
sudo netstat -tulpn | grep :80
```

### Network
```bash
# Download file
wget -c URL                         # -c tiếp tục nếu bị ngắt
curl -O URL                         # -O lưu với tên gốc
curl -o custom_name.txt URL         # -o đặt tên tùy ý

# Test API
curl -X POST -H "Content-Type: application/json" \
  -d '{"key":"value"}' http://api.example.com

# Check website response time
curl -w "@-" -o /dev/null -s http://example.com << 'EOF'
  time_total: %{time_total}s\n
EOF
```

### Quick Server
```bash
# HTTP server nhanh (Python)
python3 -m http.server 8000

# PHP server
php -S localhost:8000

# Share folder qua HTTP
cd folder && python3 -m http.server
```

---

## 14. Tips & Tricks

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

## 15. Kịch Bản Thực Hành Tổng Hợp

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

### Bài tập 4: Text processing thực tế
```bash
# Tạo file CSV
cat > employees.csv << EOF
id,name,department,salary
1,John Doe,IT,5000
2,Jane Smith,HR,4500
3,Bob Johnson,IT,5500
4,Alice Brown,Sales,4800
5,Charlie Wilson,IT,5200
EOF

# Task 1: In chỉ tên và department
cut -d ',' -f 2,3 employees.csv

# Task 2: Tìm IT department
grep "IT" employees.csv

# Task 3: Sắp xếp theo salary
sort -t ',' -k 4 -n employees.csv

# Task 4: Count employees per department
cut -d ',' -f 3 employees.csv | tail -n +2 | sort | uniq -c

# Task 5: Tổng salary của IT
grep "IT" employees.csv | cut -d ',' -f 4 | \
  paste -sd+ | bc
```

### Bài tập 5: Process management
```bash
# 1. Chạy web server background
python3 -m http.server 8000 > server.log 2>&1 &

# 2. Lưu PID
echo $! > server.pid

# 3. Check server đang chạy
cat server.pid
ps -p $(cat server.pid)

# 4. Xem log real-time
tail -f server.log

# 5. Stop server
kill $(cat server.pid)
rm server.pid
```

---

## 16. Checklist Học Tập

### 📚 Cơ bản (Beginner) - Bắt buộc phải biết
- [ ] Di chuyển thành thạo giữa các thư mục (cd, pwd, ls)
- [ ] Tạo, xóa, copy, move file và folder
- [ ] Sử dụng Vi/Vim để chỉnh sửa file cơ bản
- [ ] Dùng Sed để tìm/thay thế text
- [ ] Hiểu và áp dụng phân quyền 755, 644, 600
- [ ] Tìm kiếm file với find và grep
- [ ] Nén và giải nén file (tar, zip)
- [ ] Xem log và theo dõi file (cat, less, tail -f)

### 🔧 Trung bình (Intermediate) - Làm việc hiệu quả
- [ ] Sử dụng pipes để kết hợp commands (|, >, >>)
- [ ] Quản lý processes (ps, kill, jobs, &, nohup)
- [ ] Set environment variables và config shells
- [ ] Tạo và sử dụng symbolic links
- [ ] Xử lý text với sort, uniq, cut, wc, tr
- [ ] Viết bash scripts với logic và loops
- [ ] Dùng xargs hiệu quả
- [ ] Background/foreground job management

### ⚡ Nâng cao (Advanced) - Chuyên nghiệp
- [ ] Automation với cron jobs
- [ ] Process monitoring và optimization
- [ ] Network troubleshooting (netstat, lsof, curl)
- [ ] System performance analysis
- [ ] Xử lý large files efficiently
- [ ] Advanced text processing (awk)
- [ ] Debugging bash scripts
- [ ] Security best practices

---

## 17. Tài Nguyên Học Thêm

### Documentation
- `man command` - Xem hướng dẫn chi tiết của lệnh (ấn q để thoát)
- `command --help` - Xem trợ giúp nhanh
- `tldr command` - Examples thực tế (cần cài: `npm install -g tldr`)

### Practice Environment
- **Ubuntu VM**: Tạo máy ảo để thực hành an toàn
- **WSL**: Windows Subsystem for Linux (cho Windows 10/11)
- **Docker**: Container để test commands
- **Online**: [https://www.webminal.org](https://www.webminal.org)

### Learning Resources
- **ExplainShell**: [https://explainshell.com](https://explainshell.com) - Giải thích từng phần của command
- **Bash Guide**: [https://mywiki.wooledge.org/BashGuide](https://mywiki.wooledge.org/BashGuide)
- **Linux Journey**: [https://linuxjourney.com](https://linuxjourney.com)

### Cheat Sheets
```bash
# Download cheat sheets
curl https://github.com/LeCoupa/awesome-cheatsheets/raw/master/languages/bash.sh

# Hoặc dùng cheat.sh
curl cheat.sh/tar
curl cheat.sh/grep
```

---

## 18. Lời Khuyên Từ Teacher 👨‍🏫

### ✨ Nguyên tắc vàng
1. **Đừng cố nhớ tất cả** - Học bằng cách làm, tra khi cần
2. **Thực hành mỗi ngày** - 15 phút/ngày tốt hơn 2 giờ/tuần
3. **Hiểu logic, không học vẹt** - Hiểu tại sao, không chỉ là gì
4. **Sai là bình thường** - Backup trước khi thử nghiệm
5. **Copy-paste thông minh** - Hiểu code trước khi chạy

### 🎯 Learning Path đề xuất
```
Week 1: Basic navigation (cd, ls, pwd, mkdir, rm)
Week 2: File operations (cp, mv, cat, vim)
Week 3: Permissions & users (chmod, chown)
Week 4: Text processing (grep, sed, sort, uniq)
Week 5: Pipes & redirection
Week 6: Process management
Week 7: Bash scripting basics
Week 8: Advanced topics & automation
```

### ⚠️ Những điều TRÁNH làm
```bash
# ❌ NGUY HIỂM - ĐỪNG chạy!
rm -rf /
rm -rf /*
chmod 777 / -R
dd if=/dev/zero of=/dev/sda    # Xóa ổ cứng!

# ❌ BAD PRACTICES
sudo command    # Không hiểu command làm gì
chmod 777 file  # Cho toàn quyền mọi người
rm *            # Xóa không confirm
```

### ✅ Good Habits
```bash
# 1. Luôn backup
cp important.conf important.conf.backup

# 2. Test trước khi chạy
echo "rm file.txt"      # Echo để xem command
# rm file.txt           # Rồi mới uncomment

# 3. Dùng -i để confirm
rm -i file.txt
mv -i old new

# 4. Check manual
man rm
rm --help

# 5. Version control cho configs
git init
git add .bashrc
git commit -m "backup bashrc"
```

### 🚀 Next Steps
Sau khi học xong tài liệu này:
1. ✅ Hoàn thành tất cả bài tập trong checklist
2. ✅ Tạo 5 bash scripts của riêng bạn
3. ✅ Setup development environment với Linux
4. ✅ Học advanced topics: Awk, Regular Expressions
5. ✅ Tham gia communities: r/linux, Stack Overflow

---

**Remember**: Linux là tool, không phải mục đích. Focus vào giải quyết vấn đề thực tế!