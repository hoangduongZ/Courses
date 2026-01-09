# 10 Bài Tập Thực Hành Linux

## Bài 1: Khởi Động - Tạo Môi Trường Làm Việc

**Mục tiêu:** Làm quen với việc tạo cấu trúc thư mục và file

**Yêu cầu:**
1. Tạo thư mục `linux_practice` trong home directory
2. Bên trong tạo 3 thư mục con: `documents`, `scripts`, `backup`
3. Trong `documents` tạo 5 file text: `note1.txt` đến `note5.txt`
4. Ghi nội dung "This is note X" vào mỗi file (X là số thứ tự)
5. Liệt kê toàn bộ cấu trúc đã tạo

**Gợi ý:**
```bash
cd ~
mkdir linux_practice
# Tiếp tục...
```

**Kiểm tra:** Chạy `tree linux_practice` hoặc `ls -R linux_practice` để xem cấu trúc

---

## Bài 2: Copy và Di Chuyển File

**Mục tiêu:** Thành thạo sao chép và di chuyển file

**Yêu cầu:**
1. Copy `note1.txt` sang `backup` và đổi tên thành `note1_backup.txt`
2. Di chuyển `note2.txt` và `note3.txt` vào thư mục `scripts`
3. Copy toàn bộ thư mục `documents` thành `documents_copy`
4. Trong `documents_copy`, đổi tên `note4.txt` thành `important.txt`

**Kiểm tra:** 
- `documents` còn 2 file (note4.txt, note5.txt)
- `scripts` có 2 file (note2.txt, note3.txt)
- `backup` có 1 file (note1_backup.txt)

---

## Bài 3: Tìm Kiếm và Lọc File

**Mục tiêu:** Sử dụng find và grep

**Yêu cầu:**
1. Tìm tất cả file `.txt` trong `linux_practice`
2. Tìm file có từ "note" trong tên
3. Tạo file `logs.txt` với nội dung:
   ```
   ERROR: Database connection failed
   INFO: Server started successfully
   WARNING: Low disk space
   ERROR: Authentication failed
   INFO: User logged in
   ```
4. Tìm tất cả dòng có chữ "ERROR" trong `logs.txt`
5. Đếm có bao nhiêu dòng "ERROR"

**Gợi ý:**
```bash
find linux_practice -name "*.txt"
grep "ERROR" logs.txt
grep -c "ERROR" logs.txt
```

---

## Bài 4: Phân Quyền Cơ Bản

**Mục tiêu:** Hiểu và thay đổi quyền file

**Yêu cầu:**
1. Tạo file `public.txt` với quyền 644 (rw-r--r--)
2. Tạo file `private.txt` với quyền 600 (rw-------)
3. Tạo file `script.sh` với quyền 755 (rwxr-xr-x)
4. Xem và xác nhận quyền của từng file
5. Thử thay đổi quyền `public.txt` thành 444 (chỉ đọc cho tất cả)
6. Thử ghi vào `public.txt` và quan sát kết quả

**Kiểm tra:**
```bash
ls -l public.txt private.txt script.sh
```

**Câu hỏi:** Tại sao không ghi được vào `public.txt` sau khi chmod 444?

---

## Bài 5: Làm Việc Với Vim

**Mục tiêu:** Thực hành chỉnh sửa file với Vim

**Yêu cầu:**
1. Tạo file `shopping_list.txt` bằng vim
2. Thêm nội dung:
   ```
   Shopping List
   =============
   1. Milk
   2. Bread
   3. Eggs
   4. Coffee
   5. Sugar
   ```
3. Mở lại file, xóa dòng "3. Eggs"
4. Copy dòng "4. Coffee" và paste thành dòng mới
5. Tìm từ "Milk" trong file
6. Thay đổi "Sugar" thành "Honey"
7. Lưu và thoát

**Các phím cần dùng:**
- `dd` - xóa dòng
- `yy` - copy dòng
- `p` - paste
- `/text` - tìm kiếm
- `cw` - thay đổi từ

---

## Bài 6: Xử Lý Nội Dung File

**Mục tiêu:** Sử dụng cat, head, tail, less

**Yêu cầu:**
1. Tạo file `numbers.txt` chứa số từ 1 đến 100 (mỗi số 1 dòng)
2. Xem 10 dòng đầu tiên
3. Xem 10 dòng cuối cùng
4. Xem dòng từ 45 đến 55
5. Đếm số dòng trong file
6. Ghép 2 file `note4.txt` và `note5.txt` thành `combined.txt`

**Gợi ý:**
```bash
# Tạo file số 1-100
seq 1 100 > numbers.txt

# Xem dòng 45-55
sed -n '45,55p' numbers.txt
# hoặc
head -55 numbers.txt | tail -11

# Đếm dòng
wc -l numbers.txt
```

---

## Bài 7: Quản Lý User và Group (Nâng Cao)

**Mục tiêu:** Thực hành phân quyền user

**Yêu cầu (cần sudo):**
1. Tạo user mới tên `testuser`
2. Tạo group mới tên `developers`
3. Thêm `testuser` vào group `developers`
4. Tạo thư mục `project` với owner là `testuser` và group là `developers`
5. Set quyền 770 cho thư mục `project`
6. Xác nhận quyền và ownership

**Lệnh:**
```bash
sudo adduser testuser
sudo groupadd developers
sudo usermod -aG developers testuser
sudo mkdir project
sudo chown testuser:developers project
sudo chmod 770 project
ls -ld project
```

**Câu hỏi:** Ai có thể truy cập thư mục `project`?

---

## Bài 8: Nén và Giải Nén

**Mục tiêu:** Backup và nén dữ liệu

**Yêu cầu:**
1. Nén thư mục `documents` thành `documents_backup.tar.gz`
2. Nén thư mục `scripts` thành `scripts_backup.zip`
3. Xóa thư mục `documents` gốc
4. Giải nén `documents_backup.tar.gz` để khôi phục
5. Kiểm tra kích thước file nén vs thư mục gốc

**Lệnh:**
```bash
tar -czf documents_backup.tar.gz documents/
zip -r scripts_backup.zip scripts/

# Xem kích thước
ls -lh documents_backup.tar.gz
du -sh documents/
```

---

## Bài 9: Viết Script Bash Đơn Giản

**Mục tiêu:** Tạo script tự động hóa

**Yêu cầu:** Tạo script `cleanup.sh` thực hiện:
1. Hiển thị thông báo "Starting cleanup..."
2. Tạo thư mục `old_files` nếu chưa có
3. Di chuyển tất cả file `.txt` cũ hơn 7 ngày vào `old_files`
4. Đếm số file đã di chuyển
5. Hiển thị "Cleanup completed: X files moved"

**Template:**
```bash
#!/bin/bash

echo "Starting cleanup..."

# Tạo thư mục old_files
mkdir -p old_files

# Đếm file
count=0

# Di chuyển file .txt cũ hơn 7 ngày
# Gợi ý: find . -name "*.txt" -mtime +7

echo "Cleanup completed: $count files moved"
```

**Chạy script:**
```bash
chmod +x cleanup.sh
./cleanup.sh
```

---

## Bài 10: Dự Án Tổng Hợp - Website Log Analyzer

**Mục tiêu:** Kết hợp tất cả kỹ năng đã học

**Scenario:** Bạn là admin, cần phân tích log của web server

**Yêu cầu:**

### Bước 1: Tạo môi trường
```bash
mkdir log_analyzer
cd log_analyzer
mkdir logs reports scripts
```

### Bước 2: Tạo file log mẫu
Tạo file `logs/access.log` với nội dung:
```
192.168.1.1 - - [01/Dec/2024:10:15:23] "GET /home HTTP/1.1" 200
192.168.1.2 - - [01/Dec/2024:10:16:45] "GET /about HTTP/1.1" 200
192.168.1.1 - - [01/Dec/2024:10:17:12] "GET /login HTTP/1.1" 404
192.168.1.3 - - [01/Dec/2024:10:18:33] "POST /api/data HTTP/1.1" 500
192.168.1.2 - - [01/Dec/2024:10:19:01] "GET /home HTTP/1.1" 200
192.168.1.4 - - [01/Dec/2024:10:20:15] "GET /admin HTTP/1.1" 403
192.168.1.1 - - [01/Dec/2024:10:21:42] "GET /contact HTTP/1.1" 200
192.168.1.3 - - [01/Dec/2024:10:22:18] "POST /api/data HTTP/1.1" 500
192.168.1.5 - - [01/Dec/2024:10:23:55] "GET /products HTTP/1.1" 200
192.168.1.2 - - [01/Dec/2024:10:24:30] "GET /login HTTP/1.1" 404
```

### Bước 3: Phân tích log
Tạo script `scripts/analyze_log.sh` thực hiện:

1. **Đếm tổng số request**
2. **Đếm số lỗi 404**
3. **Đếm số lỗi 500**
4. **Liệt kê top 3 IP truy cập nhiều nhất**
5. **Tạo báo cáo vào `reports/summary.txt`**

**Script mẫu:**
```bash
#!/bin/bash

LOG_FILE="../logs/access.log"
REPORT_FILE="../reports/summary.txt"

echo "=== Web Server Log Analysis ===" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Tổng request
total=$(wc -l < $LOG_FILE)
echo "Total Requests: $total" >> $REPORT_FILE

# Lỗi 404
error_404=$(grep "404" $LOG_FILE | wc -l)
echo "404 Errors: $error_404" >> $REPORT_FILE

# Lỗi 500
error_500=$(grep "500" $LOG_FILE | wc -l)
echo "500 Errors: $error_500" >> $REPORT_FILE

echo "" >> $REPORT_FILE
echo "Top 3 IPs:" >> $REPORT_FILE

# Đếm IP và sắp xếp
awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -rn | head -3 >> $REPORT_FILE

echo "" >> $REPORT_FILE
echo "Analysis completed!"

# Hiển thị báo cáo
cat $REPORT_FILE
```

### Bước 4: Thực thi
```bash
cd scripts
chmod +x analyze_log.sh
./analyze_log.sh
```

### Bước 5: Backup
```bash
cd ..
tar -czf log_analyzer_$(date +%Y%m%d).tar.gz logs/ reports/ scripts/
```

### Kiểm tra hoàn thành:
- [ ] Có file `reports/summary.txt` với thống kê chính xác
- [ ] Script chạy không lỗi
- [ ] File backup .tar.gz được tạo thành công
- [ ] Quyền script là 755

---

## Đáp Án và Giải Thích

### Bài 1
```bash
cd ~
mkdir linux_practice
cd linux_practice
mkdir documents scripts backup
cd documents
touch note1.txt note2.txt note3.txt note4.txt note5.txt
echo "This is note 1" > note1.txt
echo "This is note 2" > note2.txt
echo "This is note 3" > note3.txt
echo "This is note 4" > note4.txt
echo "This is note 5" > note5.txt
cd ..
ls -R
```

### Bài 2
```bash
cp documents/note1.txt backup/note1_backup.txt
mv documents/note2.txt documents/note3.txt scripts/
cp -r documents documents_copy
cd documents_copy
mv note4.txt important.txt
cd ..
```

### Bài 3
```bash
find linux_practice -name "*.txt"
find linux_practice -name "*note*"
cat > logs.txt << EOF
ERROR: Database connection failed
INFO: Server started successfully
WARNING: Low disk space
ERROR: Authentication failed
INFO: User logged in
EOF
grep "ERROR" logs.txt
grep -c "ERROR" logs.txt
```

### Bài 4
```bash
touch public.txt
chmod 644 public.txt
touch private.txt
chmod 600 private.txt
touch script.sh
chmod 755 script.sh
ls -l public.txt private.txt script.sh
chmod 444 public.txt
echo "test" > public.txt  # Sẽ báo lỗi permission denied
```
**Giải thích:** Quyền 444 = r--r--r-- (chỉ đọc), không có quyền write (w) nên không ghi được.

### Bài 6
```bash
seq 1 100 > numbers.txt
head numbers.txt
tail numbers.txt
head -55 numbers.txt | tail -11
wc -l numbers.txt
cat note4.txt note5.txt > combined.txt
```

---

## Thang Điểm Tự Đánh Giá

- **Bài 1-3:** Cơ bản - Bắt buộc phải làm được
- **Bài 4-6:** Trung bình - Cần thành thạo
- **Bài 7-9:** Nâng cao - Chứng tỏ hiểu sâu
- **Bài 10:** Chuyên nghiệp - Sẵn sàng làm việc thực tế

**Mục tiêu:** Hoàn thành ít nhất 7/10 bài trong 2 tuần!

---

## Tips Khi Làm Bài

1. **Đọc kỹ yêu cầu** trước khi làm
2. **Làm từng bước** một, đừng nhảy cóc
3. **Kiểm tra kết quả** sau mỗi lệnh
4. **Ghi chú lỗi** gặp phải và cách fix
5. **Không copy-paste mù quáng**, hãy gõ tay để nhớ lâu
6. Dùng `man` hoặc `--help` khi không chắc
7. **Backup** trước khi thử lệnh nguy hiểm như `rm -rf`

Chúc bạn thực hành hiệu quả! 🚀