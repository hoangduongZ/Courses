# Module 01 — Vị trí file log quan trọng

## Mục tiêu

Biết log nào nằm ở đâu, dùng để làm gì → khi có incident biết ngay nên đọc file nào.

## Map log trên Linux

```
/var/log/
├── syslog          # Ubuntu/Debian: system messages tổng hợp
├── messages        # RHEL/CentOS: tương đương syslog
├── auth.log        # Ubuntu: SSH login, sudo, authentication
├── secure          # RHEL: tương đương auth.log
├── kern.log        # Kernel messages (driver crash, OOM killer)
├── dmesg           # Boot-time kernel ring buffer
├── cron            # Scheduled job execution (crontab)
├── mail.log        # Mail server (postfix/sendmail)
├── dpkg.log        # Package install/remove (Debian/Ubuntu)
├── apt/            # APT package manager history
├── nginx/
│   ├── access.log  # HTTP requests
│   └── error.log   # Nginx errors
├── apache2/ (hoặc httpd/)
│   ├── access.log
│   └── error.log
├── mysql/
│   └── error.log   # Database errors, slow queries
└── journal/        # systemd journal (binary, dùng journalctl)
```

## Câu hỏi thực chiến

> Khi nào đọc file nào?

| Tình huống | File log cần đọc |
|------------|-----------------|
| SSH login thất bại | `auth.log` / `secure` |
| Web server trả 500 | `nginx/error.log` |
| Server tự reboot | `kern.log` + `syslog` |
| Cron job không chạy | `cron` |
| Package bị xóa | `dpkg.log` |
| OOM (out of memory) | `kern.log` |

## Thực hành

```bash
# Chạy script khám phá môi trường mô phỏng
bash explore.sh
```

Sau đó tự trả lời các câu hỏi trong `exercise.sh`.
