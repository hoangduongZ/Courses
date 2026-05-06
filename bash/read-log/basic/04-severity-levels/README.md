# Module 04 — Log Severity Levels

## Mục tiêu

Hiểu ý nghĩa từng level → biết cái nào cần xử lý ngay, cái nào có thể bỏ qua.

## Bảng severity levels (RFC 5424 / syslog)

| Level | Số | Ý nghĩa | Cần xử lý? |
|-------|----|---------|------------|
| EMERGENCY | 0 | Hệ thống không dùng được | 🔴 Ngay lập tức |
| ALERT | 1 | Cần hành động ngay | 🔴 Ngay lập tức |
| CRITICAL | 2 | Lỗi nghiêm trọng | 🔴 Ngay lập tức |
| ERROR | 3 | Lỗi, nhưng service vẫn chạy | 🟠 Trong giờ |
| WARNING | 4 | Cảnh báo, có thể trở thành lỗi | 🟡 Trong ngày |
| NOTICE | 5 | Bình thường nhưng đáng chú ý | 🔵 Xem qua |
| INFO | 6 | Thông tin thông thường | ⚪ Theo dõi |
| DEBUG | 7 | Chi tiết để debug | ⚪ Dev only |

## Các format phổ biến trong thực tế

```
# Syslog format
May  6 09:00:00 host sshd[1234]: error: something failed

# Java/Spring Boot
2026-05-06 09:00:00.123 ERROR 1234 --- [main] c.e.MyService : NullPointerException

# Nginx
2026/05/06 09:00:00 [error] 1234#0: *42 connect() failed

# JSON log (modern apps)
{"timestamp":"2026-05-06T09:00:00Z","level":"ERROR","service":"api","message":"..."}

# Python logging
2026-05-06 09:00:00,123 ERROR mymodule - Something failed
```

## Thực hành

```bash
bash exercise.sh
```
