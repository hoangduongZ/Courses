#!/usr/bin/env bash
# Tạo môi trường mô phỏng /var/log/ để khám phá mà không cần root

set -euo pipefail

FAKE_LOG_DIR="$(dirname "$0")/fake-var-log"

echo "=== Tạo môi trường mô phỏng /var/log/ ==="
echo ""

mkdir -p "$FAKE_LOG_DIR"/{nginx,apache2,mysql,apt}

# --- syslog ---
cat > "$FAKE_LOG_DIR/syslog" << 'EOF'
May  6 08:01:01 webserver systemd[1]: Started Session 42 of user ubuntu.
May  6 08:05:32 webserver kernel: [123456.789] eth0: renamed from vethABC
May  6 08:10:00 webserver CRON[2345]: (root) CMD (/usr/bin/backup.sh)
May  6 09:00:01 webserver systemd[1]: logrotate.service: Succeeded.
May  6 09:15:44 webserver dhclient[887]: DHCPACK from 10.0.0.1
May  6 10:22:11 webserver kernel: [234567.123] EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro
EOF

# --- auth.log ---
cat > "$FAKE_LOG_DIR/auth.log" << 'EOF'
May  6 08:00:01 webserver sshd[1234]: Accepted publickey for ubuntu from 192.168.1.10 port 54321 ssh2
May  6 08:00:01 webserver sshd[1234]: pam_unix(sshd:session): session opened for user ubuntu
May  6 08:30:15 webserver sshd[2001]: Failed password for root from 45.33.32.156 port 4520 ssh2
May  6 08:30:16 webserver sshd[2001]: Failed password for root from 45.33.32.156 port 4521 ssh2
May  6 08:30:17 webserver sshd[2001]: Failed password for root from 45.33.32.156 port 4522 ssh2
May  6 08:30:18 webserver sshd[2001]: Failed password for admin from 45.33.32.156 port 4523 ssh2
May  6 08:30:19 webserver sshd[2001]: Failed password for admin from 45.33.32.156 port 4524 ssh2
May  6 08:31:00 webserver sshd[2001]: error: maximum authentication attempts exceeded for root
May  6 09:00:00 webserver sudo: ubuntu : TTY=pts/0 ; PWD=/home/ubuntu ; USER=root ; COMMAND=/bin/systemctl restart nginx
EOF

# --- kern.log ---
cat > "$FAKE_LOG_DIR/kern.log" << 'EOF'
May  6 07:59:50 webserver kernel: [     0.000000] Booting Linux on physical CPU 0x0
May  6 07:59:50 webserver kernel: [     0.000000] Linux version 5.15.0-91-generic
May  6 08:00:01 webserver kernel: [  1234.567] eth0: Link is Up - 1Gbps/Full
May  6 08:45:00 webserver kernel: [  5400.123] Out of memory: Killed process 9876 (java) total-vm:2048000kB
May  6 08:45:01 webserver kernel: [  5401.000] EXT4-fs error (device sda1): ext4_journal_check_start:61
EOF

# --- cron ---
cat > "$FAKE_LOG_DIR/cron" << 'EOF'
May  6 08:10:00 webserver CRON[2345]: (root) CMD (/usr/bin/backup.sh)
May  6 09:00:01 webserver CRON[3001]: (root) CMD (/etc/cron.daily/logrotate)
May  6 10:17:01 webserver CRON[3456]: (ubuntu) CMD (/home/ubuntu/health-check.sh)
May  6 10:17:02 webserver CRON[3457]: (ubuntu) MAIL (mailed 42 bytes of output)
EOF

# --- nginx/access.log ---
cat > "$FAKE_LOG_DIR/nginx/access.log" << 'EOF'
192.168.1.10 - - [06/May/2026:08:00:01 +0700] "GET /api/users HTTP/1.1" 200 1523 "-" "curl/7.68.0"
192.168.1.20 - - [06/May/2026:08:00:05 +0700] "POST /api/login HTTP/1.1" 200 88 "-" "Mozilla/5.0"
10.0.0.5 - - [06/May/2026:08:00:10 +0700] "GET /api/products HTTP/1.1" 200 4200 "-" "Mozilla/5.0"
45.33.32.156 - - [06/May/2026:08:30:00 +0700] "GET /wp-admin/install.php HTTP/1.1" 404 178 "-" "python-requests/2.25"
45.33.32.156 - - [06/May/2026:08:30:01 +0700] "GET /.env HTTP/1.1" 404 178 "-" "python-requests/2.25"
45.33.32.156 - - [06/May/2026:08:30:02 +0700] "GET /config.php HTTP/1.1" 404 178 "-" "python-requests/2.25"
192.168.1.10 - - [06/May/2026:09:00:00 +0700] "GET /api/orders HTTP/1.1" 500 234 "-" "curl/7.68.0"
EOF

# --- nginx/error.log ---
cat > "$FAKE_LOG_DIR/nginx/error.log" << 'EOF'
2026/05/06 09:00:00 [error] 1234#1234: *42 connect() failed (111: Connection refused) while connecting to upstream, client: 192.168.1.10, server: api.example.com, request: "GET /api/orders HTTP/1.1", upstream: "http://127.0.0.1:8080/api/orders"
2026/05/06 09:00:01 [warn] 1234#1234: *43 upstream response time 3.142, request: "GET /api/products HTTP/1.1"
2026/05/06 09:15:00 [error] 1234#1234: *99 open() "/var/www/html/favicon.ico" failed (2: No such file or directory)
EOF

# --- mysql/error.log ---
cat > "$FAKE_LOG_DIR/mysql/error.log" << 'EOF'
2026-05-06T01:00:01.123456Z 0 [Note] [MY-010116] Starting: '/usr/sbin/mysqld'
2026-05-06T08:45:00.000000Z 0 [Warning] [MY-011070] Aborted connection 42 to db: 'appdb' user: 'appuser'
2026-05-06T08:45:05.000000Z 0 [ERROR] [MY-013183] Aborting
EOF

# --- dpkg.log ---
cat > "$FAKE_LOG_DIR/dpkg.log" << 'EOF'
2026-05-06 07:30:01 startup packages configure
2026-05-06 07:30:02 install nginx:amd64 <none> 1.18.0-0ubuntu1.4
2026-05-06 07:30:05 status installed nginx:amd64 1.18.0-0ubuntu1.4
2026-05-06 07:35:10 remove curl:amd64 7.68.0-1ubuntu2.21 <none>
EOF

echo "✅ Đã tạo môi trường mô phỏng tại: $FAKE_LOG_DIR"
echo ""
echo "=== Cấu trúc thư mục ==="
find "$FAKE_LOG_DIR" -type f | sort | sed "s|$FAKE_LOG_DIR|/var/log (mô phỏng)|"
echo ""
echo "=== Thống kê ==="
for f in syslog auth.log kern.log cron nginx/access.log nginx/error.log mysql/error.log dpkg.log; do
    lines=$(wc -l < "$FAKE_LOG_DIR/$f")
    echo "  $f: $lines dòng"
done
echo ""
echo "▶  Tiếp theo: chạy 'bash exercise.sh' để làm bài tập"
