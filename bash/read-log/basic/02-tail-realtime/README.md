# Module 02 — tail -f: Theo dõi log realtime

## Mục tiêu

Dùng `tail -f` (và các biến thể) để bám sát log đang chạy — kỹ năng số 1 khi debug production.

## Lý thuyết cốt lõi

```bash
tail -f /var/log/nginx/access.log        # follow file, in dòng mới khi append
tail -F /var/log/nginx/access.log        # follow tên file (tự reconnect khi logrotate)
tail -n 50 -f /var/log/syslog            # xem 50 dòng cuối rồi follow
tail -f file1.log file2.log              # follow nhiều file cùng lúc
```

### tail -f vs tail -F

| | `-f` | `-F` |
|--|------|------|
| Khi file bị xóa/rotate | Dừng theo dõi | Tự reconnect file mới |
| Dùng khi | Test nhanh | Production (logrotate) |

### Kết hợp với grep (pipe)

```bash
# Chỉ hiện dòng có ERROR
tail -f app.log | grep "ERROR"

# Highlight từ khóa (GNU grep)
tail -f app.log | grep --color=always -E "ERROR|WARN|"

# Lọc nhiều pattern
tail -f app.log | grep -E "ERROR|CRITICAL|FATAL"
```

## Thực hành

```bash
# Terminal 1: chạy log generator (mô phỏng server đang chạy)
bash simulate-log.sh

# Terminal 2: theo dõi log
tail -f /tmp/practice-app.log
tail -f /tmp/practice-app.log | grep "ERROR"
tail -f /tmp/practice-app.log | grep -E "ERROR|WARN"
```

Sau đó chạy:
```bash
bash exercise.sh
```
