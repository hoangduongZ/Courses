# Module 03 — grep: Tìm lỗi trong log

## Mục tiêu

Dùng `grep` để tìm đúng thứ mình cần trong hàng nghìn dòng log.

## Lý thuyết cốt lõi

```bash
grep "ERROR" app.log                    # tìm dòng chứa "ERROR"
grep -i "error" app.log                 # case-insensitive
grep -n "ERROR" app.log                 # hiện số dòng
grep -c "ERROR" app.log                 # đếm số dòng match
grep -v "INFO" app.log                  # loại trừ dòng chứa INFO
grep -A 3 "ERROR" app.log               # in 3 dòng SAU match (After)
grep -B 2 "ERROR" app.log               # in 2 dòng TRƯỚC match (Before)
grep -C 2 "ERROR" app.log               # in 2 dòng trước+sau (Context)
grep -E "ERROR|WARN|FATAL" app.log      # regex: nhiều pattern
grep -r "ERROR" /var/log/nginx/         # tìm trong thư mục (recursive)
grep --color=auto "ERROR" app.log       # highlight kết quả
```

## Các pattern thực chiến

```bash
# Tìm SSH brute force
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn

# Tìm HTTP 500 errors
grep '" 500 ' /var/log/nginx/access.log

# Tìm lỗi trong khoảng thời gian
grep "May  6 09:" /var/log/syslog

# Lọc IP cụ thể
grep "45.33.32.156" /var/log/nginx/access.log

# Tìm OOM killer
grep -i "out of memory\|oom\|killed process" /var/log/kern.log
```

## Thực hành

```bash
# Tạo sample log
bash generate-sample.sh

# Làm bài exercise (có đáp án ẩn)
bash exercise.sh
```
