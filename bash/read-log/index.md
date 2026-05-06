# 📋 Linux & Shell — Đọc Log: Từ Basic đến Enterprise

> **Mục tiêu:** Nắm vững kỹ năng đọc, phân tích, và xử lý log trên Linux — từ người mới bắt đầu đến kỹ sư vận hành hệ thống doanh nghiệp.

---

## 📌 MỤC LỤC

1. [Hiểu cấu trúc Log trong Linux](#1-hiểu-cấu-trúc-log-trong-linux)
2. [Các file log quan trọng](#2-các-file-log-quan-trọng)
3. [Basic — Đọc log cơ bản](#3-basic--đọc-log-cơ-bản)
4. [Intermediate — Lọc và tìm kiếm log](#4-intermediate--lọc-và-tìm-kiếm-log)
5. [Advanced — Phân tích log nâng cao](#5-advanced--phân-tích-log-nâng-cao)
6. [Systemd & journalctl](#6-systemd--journalctl)
7. [Log Rotation — Quản lý vòng đời log](#7-log-rotation--quản-lý-vòng-đời-log)
8. [Enterprise — Tập trung log & giám sát](#8-enterprise--tập-trung-log--giám-sát)
9. [Bảo mật Log (Security Logging)](#9-bảo-mật-log-security-logging)
10. [Checklist thực chiến](#10-checklist-thực-chiến)

---

## 1. Hiểu cấu trúc Log trong Linux

### Log là gì?
Log là các bản ghi sự kiện được hệ thống, ứng dụng, hoặc kernel tạo ra để theo dõi hoạt động, lỗi, và trạng thái.

### Hệ thống logging Linux

```
Kernel / Applications
        │
        ▼
   syslog / rsyslog / syslog-ng
        │
        ▼
  /var/log/*.log   ←→   journald (systemd)
        │
        ▼
  Log Collector (Fluentd / Filebeat / Vector)
        │
        ▼
  Centralized Platform (ELK / Loki / Splunk)
```

### Cấu trúc một dòng log chuẩn (Syslog format)

```
May  6 08:15:32 webserver sshd[1234]: Failed password for root from 10.0.0.5 port 22
│              │           │    │      │
│              │           │    │      └─ Nội dung sự kiện
│              │           │    └──────── PID của process
│              │           └───────────── Tên process/service
│              └───────────────────────── Hostname
└──────────────────────────────────────── Timestamp
```

### Log Severity Levels (RFC 5424)

| Level | Số | Ý nghĩa |
|-------|----|---------|
| EMERGENCY | 0 | Hệ thống không sử dụng được |
| ALERT | 1 | Cần hành động ngay |
| CRITICAL | 2 | Điều kiện nghiêm trọng |
| ERROR | 3 | Lỗi cần xử lý |
| WARNING | 4 | Cảnh báo |
| NOTICE | 5 | Bình thường nhưng đáng chú ý |
| INFO | 6 | Thông tin hoạt động |
| DEBUG | 7 | Debug chi tiết |

---

## 2. Các file log quan trọng

```bash
/var/log/
├── syslog           # Log hệ thống chung (Debian/Ubuntu)
├── messages         # Log hệ thống chung (RHEL/CentOS)
├── auth.log         # Xác thực, SSH, sudo (Debian/Ubuntu)
├── secure           # Xác thực (RHEL/CentOS)
├── kern.log         # Kernel messages
├── dmesg            # Boot + hardware messages
├── boot.log         # Quá trình khởi động
├── cron             # Cron jobs
├── mail.log         # Mail server
├── dpkg.log         # Package install/remove (Debian)
├── yum.log          # Package install/remove (RHEL)
├── apache2/
│   ├── access.log   # HTTP requests
│   └── error.log    # Lỗi web server
├── nginx/
│   ├── access.log
│   └── error.log
└── mysql/
    └── error.log
```

---

## 3. Basic — Đọc log cơ bản

### Xem toàn bộ file log

```bash
cat /var/log/syslog
```

### Xem log với phân trang

```bash
less /var/log/syslog
# Phím tắt: q=thoát, /từ=tìm kiếm, n=tiếp theo, G=cuối file
```

### Xem N dòng cuối

```bash
tail /var/log/syslog          # 10 dòng cuối (mặc định)
tail -n 50 /var/log/syslog    # 50 dòng cuối
tail -n 100 /var/log/auth.log
```

### Theo dõi log realtime (live tail)

```bash
tail -f /var/log/syslog
tail -f /var/log/nginx/access.log
```

### Xem N dòng đầu

```bash
head -n 20 /var/log/syslog
```

### Xem log kernel sau khi boot

```bash
dmesg
dmesg | less
dmesg -T               # Hiển thị timestamp dễ đọc
dmesg --level=err,warn # Chỉ hiện lỗi và cảnh báo
```

---

## 4. Intermediate — Lọc và tìm kiếm log

### grep — Tìm kiếm từ khóa

```bash
# Tìm lỗi
grep "error" /var/log/syslog
grep -i "error" /var/log/syslog    # Không phân biệt hoa/thường

# Tìm nhiều từ khóa
grep -E "error|failed|critical" /var/log/syslog

# Xem context xung quanh dòng tìm được
grep -A 3 -B 2 "Failed password" /var/log/auth.log
# -A: after (dòng sau), -B: before (dòng trước)

# Đếm số lần xuất hiện
grep -c "Failed password" /var/log/auth.log

# Tìm kiếm đệ quy trong thư mục
grep -r "OutOfMemory" /var/log/

# Tìm IP cụ thể trong access log
grep "192.168.1.100" /var/log/nginx/access.log
```

### awk — Xử lý cột/trường dữ liệu

```bash
# In cột 1 và 5 (timestamp và service)
awk '{print $1, $5}' /var/log/syslog

# Đếm request theo HTTP status code trong nginx log
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn

# Lọc dòng có cột thứ 6 là "error"
awk '$6 == "error"' /var/log/syslog

# Tính tổng bytes transfer
awk '{sum += $10} END {print "Total bytes:", sum}' /var/log/nginx/access.log
```

### sed — Xử lý và biến đổi log

```bash
# Xóa dòng trống
sed '/^$/d' /var/log/syslog

# Thay thế chuỗi trong output
sed 's/192.168.1.100/INTERNAL_IP/g' /var/log/nginx/access.log

# In từ dòng 100 đến 200
sed -n '100,200p' /var/log/syslog
```

### Lọc log theo thời gian

```bash
# Xem log từ ngày cụ thể (với awk)
awk '/May  5/,/May  6/' /var/log/syslog

# Lọc log trong khoảng giờ cụ thể
grep "May  6 09:" /var/log/syslog
grep "May  6 1[0-2]:" /var/log/syslog   # 10h-12h

# Kết hợp pipe
grep "May  6" /var/log/auth.log | grep -i "failed" | wc -l
```

### Thống kê nhanh

```bash
# Top 10 IP truy cập nhiều nhất
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head 10

# Top user agent
awk -F'"' '{print $6}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head 5

# Đếm lỗi theo giờ
grep "error" /var/log/nginx/error.log | awk '{print $1, $2}' | cut -d: -f1,2 | uniq -c
```

---

## 5. Advanced — Phân tích log nâng cao

### Phân tích log với nhiều file cùng lúc

```bash
# Đọc nhiều file log cùng lúc
cat /var/log/syslog /var/log/kern.log | grep "error"

# Theo dõi nhiều file realtime
tail -f /var/log/syslog -f /var/log/auth.log

# Xử lý file log nén (.gz) không cần giải nén
zcat /var/log/syslog.1.gz | grep "error"
zgrep "error" /var/log/syslog.*.gz
```

### Regex nâng cao với grep

```bash
# Tìm địa chỉ IP
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' /var/log/auth.log

# Tìm dòng KHÔNG chứa từ khóa
grep -v "DEBUG" /var/log/app.log

# Tìm nhiều pattern từ file
grep -f patterns.txt /var/log/syslog
```

### Script phân tích log cơ bản

```bash
#!/bin/bash
# log_analyze.sh - Phân tích nhanh log hệ thống

LOG_FILE="${1:-/var/log/syslog}"
DATE=$(date '+%b %e')

echo "=== LOG ANALYSIS: $LOG_FILE ==="
echo "=== Date: $DATE ==="
echo ""

echo "📊 Tổng số dòng log hôm nay:"
grep "$DATE" "$LOG_FILE" | wc -l

echo ""
echo "🔴 Lỗi (ERROR/CRIT/EMERG):"
grep -iE "error|critical|emerg" "$LOG_FILE" | grep "$DATE" | wc -l

echo ""
echo "⚠️  Cảnh báo (WARNING):"
grep -i "warning" "$LOG_FILE" | grep "$DATE" | wc -l

echo ""
echo "🔐 SSH Failed login hôm nay:"
grep "$DATE" /var/log/auth.log 2>/dev/null | grep "Failed password" | wc -l

echo ""
echo "🔝 Top 5 services có lỗi:"
grep -i "error" "$LOG_FILE" | grep "$DATE" | awk '{print $5}' | sort | uniq -c | sort -rn | head 5
```

```bash
chmod +x log_analyze.sh
./log_analyze.sh /var/log/syslog
```

---

## 6. Systemd & journalctl

Trên các hệ thống dùng `systemd`, `journalctl` là công cụ chính để đọc log.

### Lệnh journalctl cơ bản

```bash
journalctl                     # Toàn bộ log
journalctl -n 50               # 50 dòng cuối
journalctl -f                  # Follow (realtime)
journalctl --no-pager          # Không dùng pager
```

### Lọc theo service

```bash
journalctl -u nginx            # Log của nginx
journalctl -u sshd -u nginx    # Nhiều services
journalctl -u docker --since today
```

### Lọc theo thời gian

```bash
journalctl --since "2024-05-06 08:00:00"
journalctl --since "2024-05-06 08:00:00" --until "2024-05-06 09:00:00"
journalctl --since "1 hour ago"
journalctl --since yesterday
journalctl --since today
```

### Lọc theo priority (level)

```bash
journalctl -p err              # Chỉ ERROR trở lên
journalctl -p warning          # WARNING trở lên
journalctl -p debug            # Tất cả (debug và trên)

# Khoảng priority
journalctl -p err..warning     # Từ ERR đến WARNING
```

### Output format

```bash
journalctl -o json             # JSON format
journalctl -o json-pretty      # JSON đẹp
journalctl -o short-precise    # Timestamp chính xác
journalctl -o verbose          # Chi tiết tối đa
journalctl -o cat              # Chỉ nội dung message
```

### Xem log của boot lần trước

```bash
journalctl --list-boots        # Danh sách lần boot
journalctl -b                  # Boot hiện tại
journalctl -b -1               # Boot trước đó
journalctl -b -2               # 2 boot trước
```

### Tìm kiếm trong journalctl

```bash
journalctl -u nginx | grep "error"
journalctl _PID=1234           # Lọc theo PID
journalctl _UID=1000           # Lọc theo user ID
journalctl _HOSTNAME=webserver # Lọc theo hostname
```

### Dung lượng journal

```bash
journalctl --disk-usage        # Xem dung lượng đang dùng
journalctl --vacuum-size=500M  # Giữ tối đa 500MB
journalctl --vacuum-time=7d    # Xóa log cũ hơn 7 ngày
```

---

## 7. Log Rotation — Quản lý vòng đời log

### Cấu hình logrotate

```bash
# File cấu hình chính
cat /etc/logrotate.conf

# Cấu hình riêng từng ứng dụng
ls /etc/logrotate.d/
```

### Ví dụ cấu hình logrotate cho ứng dụng

```bash
# /etc/logrotate.d/myapp
/var/log/myapp/*.log {
    daily                  # Rotate hàng ngày
    missingok              # Không lỗi nếu file không tồn tại
    rotate 30              # Giữ 30 bản backup
    compress               # Nén file log cũ
    delaycompress          # Nén từ lần rotate thứ 2
    notifempty             # Không rotate nếu file trống
    create 0640 www-data adm  # Tạo file mới với quyền này
    sharedscripts
    postrotate
        systemctl reload nginx > /dev/null 2>&1 || true
    endscript
}
```

### Kiểm tra và chạy thủ công

```bash
logrotate -d /etc/logrotate.d/nginx    # Dry run (debug mode)
logrotate -f /etc/logrotate.d/nginx    # Force rotate ngay
```

---

## 8. Enterprise — Tập trung log & giám sát

### Kiến trúc Centralized Logging

```
[Server 1]──┐
[Server 2]──┤──▶ Log Shipper ──▶ Message Queue ──▶ Indexer/Store ──▶ Dashboard
[Server N]──┘   (Filebeat/      (Kafka/Redis)      (Elasticsearch   (Kibana/
                 Fluentd/                            /Loki/ClickHouse) Grafana)
                 Vector)
```

### Stack phổ biến

| Stack | Thành phần | Use case |
|-------|-----------|---------|
| **ELK** | Elasticsearch + Logstash + Kibana | Full-text search, phân tích phức tạp |
| **EFK** | Elasticsearch + Fluentd + Kibana | Kubernetes, cloud-native |
| **PLG** | Promtail + Loki + Grafana | Nhẹ hơn, tốt cho metrics kết hợp |
| **Splunk** | Splunk Enterprise | Enterprise có ngân sách, compliance |

### Cấu hình rsyslog gửi log đến server tập trung

```bash
# /etc/rsyslog.conf — Trên máy client

# Gửi tất cả log qua TCP đến log server
*.* @@logserver.company.com:514

# Gửi chỉ auth log
auth,authpriv.* @@logserver.company.com:514

# Gửi qua UDP (ít tin cậy hơn nhưng nhẹ hơn)
*.* @logserver.company.com:514
```

```bash
# Trên log server — nhận log
# /etc/rsyslog.conf
module(load="imtcp")
input(type="imtcp" port="514")

# Lưu theo hostname
template(name="RemoteLogs" type="string"
  string="/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log")
*.* ?RemoteLogs
```

### Filebeat — Thu thập log gửi đến Elasticsearch

```yaml
# /etc/filebeat/filebeat.yml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/nginx/access.log
      - /var/log/nginx/error.log
    fields:
      service: nginx
      environment: production
    fields_under_root: true

  - type: log
    paths:
      - /var/log/app/*.log
    multiline.pattern: '^\d{4}-\d{2}-\d{2}'
    multiline.negate: true
    multiline.match: after

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "logs-%{[environment]}-%{+yyyy.MM.dd}"

processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
```

### Fluentd — Xử lý và định tuyến log

```xml
<!-- /etc/fluent/fluent.conf -->
<source>
  @type tail
  path /var/log/nginx/access.log
  pos_file /var/log/td-agent/nginx-access.pos
  tag nginx.access
  <parse>
    @type nginx
  </parse>
</source>

<filter nginx.access>
  @type record_transformer
  <record>
    hostname "#{Socket.gethostname}"
    environment "production"
  </record>
</filter>

<match nginx.access>
  @type elasticsearch
  host elasticsearch
  port 9200
  index_name nginx-logs
  type_name _doc
</match>
```

### Cấu hình Logstash pipeline

```ruby
# /etc/logstash/conf.d/nginx.conf
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][service] == "nginx" {
    grok {
      match => {
        "message" => '%{COMBINEDAPACHELOG}'
      }
    }
    date {
      match => ["timestamp", "dd/MMM/yyyy:HH:mm:ss Z"]
    }
    geoip {
      source => "clientip"
    }
    useragent {
      source => "agent"
      target => "useragent"
    }
  }
}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "nginx-logs-%{+YYYY.MM.dd}"
  }
}
```

### Grafana Loki — Logging stack nhẹ

```yaml
# promtail config (agent thu log)
server:
  http_listen_port: 9080

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          host: webserver01
          __path__: /var/log/*log

  - job_name: nginx
    static_configs:
      - targets:
          - localhost
        labels:
          job: nginx
          __path__: /var/log/nginx/*log
```

---

## 9. Bảo mật Log (Security Logging)

### Theo dõi đăng nhập và xác thực

```bash
# Xem tất cả lần đăng nhập
last                           # Lịch sử đăng nhập
lastlog                        # Lần đăng nhập cuối của mỗi user
lastb                          # Đăng nhập thất bại (cần root)
who                            # User đang đăng nhập hiện tại
w                              # User đăng nhập + đang làm gì

# Phát hiện brute force SSH
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | head 20

# IP đã bị block bởi fail2ban
fail2ban-client status sshd
```

### Giám sát thay đổi file quan trọng (auditd)

```bash
# Cài đặt auditd
apt install auditd   # Debian/Ubuntu
yum install audit    # RHEL/CentOS

# Theo dõi thay đổi file /etc/passwd
auditctl -w /etc/passwd -p wa -k user_modification
auditctl -w /etc/sudoers -p wa -k sudoers_change
auditctl -w /var/log/ -p wa -k log_modification

# Xem audit log
ausearch -k user_modification
ausearch -k user_modification --start today
aureport --auth           # Báo cáo xác thực
aureport --failed         # Báo cáo lỗi
```

```bash
# Cấu hình audit vĩnh viễn
# /etc/audit/rules.d/audit.rules
-w /etc/passwd -p wa -k passwd_changes
-w /etc/group -p wa -k group_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /var/log/auth.log -p wa -k auth_log_access
-a always,exit -F arch=b64 -S execve -k command_exec
```

### Log integrity — Bảo vệ tính toàn vẹn log

```bash
# Cấu hình rsyslog ghi log sang server khác ngay lập tức
# (đề phòng attacker xóa log local)

# Forward sang remote syslog server
echo "*.* @@secure-logserver.company.com:514" >> /etc/rsyslog.conf

# Cấu hình journald không cho phép xóa
# /etc/systemd/journald.conf
[Journal]
Storage=persistent
Seal=yes                    # Seal journal để phát hiện tampering
ForwardToSyslog=yes
```

### Monitoring alerts với shell script

```bash
#!/bin/bash
# security_monitor.sh — Chạy qua cron mỗi 5 phút

ALERT_EMAIL="admin@company.com"
THRESHOLD_SSH_FAIL=20
THRESHOLD_SU_FAIL=5

# Đếm SSH failed trong 5 phút qua
SSH_FAILS=$(journalctl -u sshd --since "5 minutes ago" | grep -c "Failed password")

if [ "$SSH_FAILS" -gt "$THRESHOLD_SSH_FAIL" ]; then
    echo "⚠️  ALERT: $SSH_FAILS SSH failures in last 5 minutes on $(hostname)" \
    | mail -s "SSH Brute Force Alert" "$ALERT_EMAIL"
fi

# Kiểm tra su/sudo failures
SU_FAILS=$(journalctl --since "5 minutes ago" | grep -c "authentication failure")

if [ "$SU_FAILS" -gt "$THRESHOLD_SU_FAIL" ]; then
    echo "⚠️  ALERT: $SU_FAILS auth failures on $(hostname)" \
    | mail -s "Authentication Failure Alert" "$ALERT_EMAIL"
fi
```

---

## 10. Checklist thực chiến

### 🔵 Basic (Mới bắt đầu)
- [ ] Biết vị trí các file log quan trọng trong `/var/log/`
- [ ] Sử dụng `tail -f` để theo dõi log realtime
- [ ] Dùng `grep` để tìm lỗi cơ bản
- [ ] Hiểu log severity levels

### 🟡 Intermediate
- [ ] Kết hợp `grep`, `awk`, `sed` để phân tích log
- [ ] Sử dụng `journalctl` với các filter thời gian và service
- [ ] Viết script shell đơn giản để phân tích log
- [ ] Hiểu và cấu hình `logrotate`

### 🟠 Advanced
- [ ] Xử lý log nén (`.gz`) không cần giải nén
- [ ] Dùng `auditd` để audit hành động hệ thống
- [ ] Phát hiện brute force và security incidents qua log
- [ ] Viết script alert tự động

### 🔴 Enterprise
- [ ] Triển khai centralized logging (ELK/PLG/Splunk)
- [ ] Cấu hình log shipper (Filebeat/Fluentd/Vector)
- [ ] Thiết lập retention policy và log rotation tập trung
- [ ] Xây dựng dashboard giám sát trên Kibana/Grafana
- [ ] Tích hợp SIEM (Security Information and Event Management)
- [ ] Log integrity và audit trail cho compliance (PCI-DSS, ISO 27001)

---

## 📚 Tài nguyên học thêm

| Chủ đề | Lệnh/Tool |
|--------|-----------|
| Man page chi tiết | `man journalctl`, `man rsyslog.conf`, `man logrotate` |
| Test regex log | https://grokdebugger.com |
| ELK Stack docs | https://www.elastic.co/guide |
| Grafana Loki | https://grafana.com/docs/loki |
| Linux audit | `man auditctl`, `man ausearch` |

---

> 💡 **Tip thực chiến:** Khi xử lý incident, luôn bắt đầu với `journalctl -p err --since "1 hour ago"` để có cái nhìn tổng quan nhanh về lỗi hệ thống trong 1 giờ qua trước khi đi sâu vào từng service cụ thể.