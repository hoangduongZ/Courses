# Hướng dẫn cài máy ảo Linux trên macOS để mô phỏng case Enterprise

## 1. Mục tiêu

Tài liệu này hướng dẫn cách dựng một môi trường Linux Lab trên macOS để luyện các kỹ năng gần với môi trường enterprise:

- Cài máy ảo Linux trên macOS
- Dựng nhiều server mô phỏng hệ thống thật
- Có Web Server, App Server, Database Server
- Sinh log thật để luyện đọc log
- Mô phỏng các lỗi production thường gặp:
  - Nginx 502 Bad Gateway
  - App service chết
  - Database down
  - Network bị chặn
  - Permission denied
  - Disk full
  - Log rotation
- Luyện debug theo flow enterprise:
  - User request → Web server → App server → Database

---

# 2. Chọn công cụ máy ảo trên macOS

## 2.1. Khuyến nghị: UTM

Với macOS, đặc biệt là Mac M1/M2/M3/M4, nên dùng **UTM**.

Ưu điểm:

- Dễ dùng
- Miễn phí
- Hỗ trợ tốt Apple Silicon
- Tạo nhiều VM Linux dễ dàng
- Phù hợp để học Linux, Shell, Log, Network, Service

Trang tải:

```text
https://mac.getutm.app/
```

## 2.2. Phương án khác: Multipass

Nếu bạn muốn tạo Ubuntu VM nhanh bằng command line, có thể dùng **Multipass**.

Ví dụ:

```bash
multipass launch
multipass list
multipass shell <vm-name>
```

Multipass phù hợp để tạo VM nhanh, nhưng để mô phỏng enterprise rõ ràng, dễ quản lý nhiều server, nên ưu tiên UTM.

---

# 3. Kiến trúc Lab Enterprise nên dựng

Không nên chỉ cài 1 máy Linux. Enterprise thường có nhiều tầng.

Mô hình đề xuất:

```text
macOS Host
│
└── Enterprise Lab Network
    │
    ├── web01
    │   ├── Nginx reverse proxy
    │   ├── /var/log/nginx/access.log
    │   └── /var/log/nginx/error.log
    │
    ├── app01
    │   ├── App server
    │   ├── systemd service
    │   └── app.log
    │
    └── db01
        ├── PostgreSQL hoặc MySQL
        └── Database log
```

## 3.1. Cấu hình VM đề xuất

| VM | Vai trò | RAM | CPU | Disk |
|---|---|---:|---:|---:|
| `web01` | Nginx reverse proxy | 1–2GB | 1 core | 15–20GB |
| `app01` | App server | 2GB | 1–2 cores | 20GB |
| `db01` | Database server | 2GB | 1–2 cores | 20–30GB |

## 3.2. Nếu Mac RAM yếu

Nếu Mac có RAM 8GB:

- Chạy 2 VM trước:
  - `web01`
  - `app01`
- Database có thể cài chung trên `app01` để tiết kiệm RAM

Nếu Mac có RAM 16GB trở lên:

- Chạy 3 VM là hợp lý:
  - `web01`
  - `app01`
  - `db01`

---

# 4. Tải Linux ISO phù hợp

## 4.1. Nếu Mac Apple Silicon M1/M2/M3/M4

Tải Ubuntu Server ARM64:

```text
Ubuntu Server 24.04 LTS ARM64
```

## 4.2. Nếu Mac Intel

Tải Ubuntu Server AMD64:

```text
Ubuntu Server 24.04 LTS AMD64
```

Khuyến nghị dùng bản Server, không dùng Desktop, vì:

- Nhẹ hơn
- Sát môi trường server thật hơn
- Bắt buộc thao tác bằng terminal
- Phù hợp học Linux/Shell/Log

---

# 5. Cài VM Linux bằng UTM

## 5.1. Tạo VM mới

Mở UTM:

```text
Create a New Virtual Machine
```

Chọn:

```text
Virtualize
```

Chọn:

```text
Linux
```

Chọn file ISO Ubuntu Server đã tải.

---

## 5.2. Cấu hình VM mẫu

Ví dụ với VM `web01`:

```text
Name: web01
CPU: 1 core
RAM: 2048 MB
Disk: 20 GB
Network: Shared Network hoặc Bridged
```

## 5.3. Network nên chọn gì?

### Bridged Network

Ưu điểm:

- VM có IP cùng mạng LAN với Mac
- Dễ SSH từ Mac vào VM
- Các VM gọi nhau dễ hơn

Nhược điểm:

- Có thể không ổn định tùy Wi-Fi/router

### Shared Network

Ưu điểm:

- Dễ dùng
- Ổn định hơn trong nhiều trường hợp

Nhược điểm:

- IP VM nằm trong mạng NAT
- Cần kiểm tra kỹ nếu muốn các VM gọi nhau

Khuyến nghị:

```text
Ưu tiên Bridged nếu chạy ổn.
Nếu Bridged lỗi hoặc không có IP, dùng Shared Network.
```

---

# 6. Cài Ubuntu Server

Trong quá trình cài đặt:

```text
Hostname: web01
Username: lab
Password: đặt password dễ nhớ
Install OpenSSH Server: YES
```

Điểm quan trọng nhất:

```text
Phải bật Install OpenSSH Server
```

Vì sau này bạn sẽ SSH từ macOS vào VM.

---

# 7. Sau khi cài xong VM

Login vào VM và chạy:

```bash
sudo apt update
sudo apt upgrade -y
```

Cài tool cơ bản:

```bash
sudo apt install -y vim curl wget net-tools htop tree unzip zip lsof tcpdump rsyslog logrotate
```

Kiểm tra IP:

```bash
ip a
```

Hoặc:

```bash
hostname -I
```

Từ macOS SSH vào VM:

```bash
ssh lab@<IP_VM>
```

Ví dụ:

```bash
ssh lab@192.168.64.10
```

---

# 8. Tạo 3 máy enterprise lab

Lặp lại quá trình cài VM để tạo:

```text
web01
app01
db01
```

Sau khi cài xong, có thể sửa hostname:

```bash
sudo hostnamectl set-hostname web01
```

Hoặc:

```bash
sudo hostnamectl set-hostname app01
```

Hoặc:

```bash
sudo hostnamectl set-hostname db01
```

Kiểm tra:

```bash
hostname
```

---

# 9. Cấu hình `/etc/hosts`

Mục tiêu là để các server gọi nhau bằng hostname thay vì IP.

Trên cả 3 VM, mở file:

```bash
sudo vim /etc/hosts
```

Thêm IP tương ứng:

```text
192.168.64.10 web01
192.168.64.11 app01
192.168.64.12 db01
```

Kiểm tra kết nối:

```bash
ping app01
ping db01
```

Nếu ping không được, kiểm tra lại:

```bash
ip a
cat /etc/hosts
```

---

# 10. Cài Web Server trên `web01`

## 10.1. Cài Nginx

Trên `web01`:

```bash
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

Kiểm tra trạng thái:

```bash
systemctl status nginx
```

## 10.2. Log quan trọng của Nginx

```text
/var/log/nginx/access.log
/var/log/nginx/error.log
```

Xem realtime access log:

```bash
sudo tail -f /var/log/nginx/access.log
```

Xem realtime error log:

```bash
sudo tail -f /var/log/nginx/error.log
```

---

# 11. Cài Database Server trên `db01`

## 11.1. Cài PostgreSQL

Trên `db01`:

```bash
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

Kiểm tra:

```bash
systemctl status postgresql
```

## 11.2. Log PostgreSQL

Log thường nằm tại:

```text
/var/log/postgresql/
```

Xem:

```bash
sudo ls -lah /var/log/postgresql/
sudo tail -f /var/log/postgresql/*.log
```

---

# 12. Tạo App Server giả lập trên `app01`

## 12.1. Cài Java

Trên `app01`:

```bash
sudo apt install -y openjdk-21-jdk
java -version
```

## 12.2. Tạo thư mục app

```bash
mkdir -p ~/enterprise-lab/logs
cd ~/enterprise-lab
```

## 12.3. Tạo fake app sinh log

Tạo file:

```bash
vim fake-app.sh
```

Nội dung:

```bash
#!/bin/bash

LOG_FILE="$HOME/enterprise-lab/logs/app.log"

while true; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') INFO requestId=$(uuidgen) userId=1001 endpoint=/api/orders status=200 duration=120ms" >> "$LOG_FILE"
  sleep 1

  if (( RANDOM % 5 == 0 )); then
    echo "$(date '+%Y-%m-%d %H:%M:%S') WARN requestId=$(uuidgen) message='Slow query detected' duration=2500ms" >> "$LOG_FILE"
  fi

  if (( RANDOM % 10 == 0 )); then
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR requestId=$(uuidgen) exception='Database timeout' dbHost=db01 duration=5000ms" >> "$LOG_FILE"
  fi
done
```

Cấp quyền chạy:

```bash
chmod +x fake-app.sh
```

Chạy thử:

```bash
./fake-app.sh
```

Mở tab SSH khác để xem log:

```bash
tail -f ~/enterprise-lab/logs/app.log
```

---

# 13. Biến fake app thành systemd service

Enterprise thường không chạy app thủ công, mà chạy qua `systemd`.

## 13.1. Tạo service file

```bash
sudo vim /etc/systemd/system/fake-app.service
```

Nội dung:

```ini
[Unit]
Description=Fake Enterprise App
After=network.target

[Service]
Type=simple
User=lab
WorkingDirectory=/home/lab/enterprise-lab
ExecStart=/home/lab/enterprise-lab/fake-app.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## 13.2. Reload systemd

```bash
sudo systemctl daemon-reload
```

## 13.3. Start service

```bash
sudo systemctl enable fake-app
sudo systemctl start fake-app
```

Kiểm tra:

```bash
systemctl status fake-app
```

Xem log systemd:

```bash
journalctl -u fake-app -f
```

Xem app log:

```bash
tail -f /home/lab/enterprise-lab/logs/app.log
```

---

# 14. Cấu hình Nginx reverse proxy từ `web01` sang `app01`

Trên `web01`, tạo config:

```bash
sudo vim /etc/nginx/sites-available/enterprise-lab
```

Nội dung:

```nginx
server {
    listen 80;
    server_name enterprise-lab.local;

    access_log /var/log/nginx/enterprise_access.log;
    error_log  /var/log/nginx/enterprise_error.log;

    location / {
        proxy_pass http://app01:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Enable config:

```bash
sudo ln -s /etc/nginx/sites-available/enterprise-lab /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Hiện tại fake app chưa listen port 8080, nên khi gọi sẽ tạo lỗi rất tốt để luyện debug:

```bash
curl http://web01
```

Xem lỗi:

```bash
sudo tail -f /var/log/nginx/enterprise_error.log
```

Bạn có thể thấy lỗi dạng:

```text
connect() failed
connection refused
upstream
```

Đây là case enterprise rất thực tế:

```text
Nginx reverse proxy không gọi được App Server
```

---

# 15. Các case enterprise nên mô phỏng

## Case 1: Service chết

Trên `app01`:

```bash
sudo systemctl stop fake-app
```

Kiểm tra:

```bash
systemctl status fake-app
journalctl -u fake-app -n 50 --no-pager
```

Bật lại:

```bash
sudo systemctl start fake-app
```

---

## Case 2: Nginx 502 Bad Gateway

Trên `web01`, cấu hình Nginx proxy sang port app không tồn tại:

```nginx
proxy_pass http://app01:8080;
```

Nếu app không chạy ở port đó, Nginx sẽ báo lỗi upstream.

Test:

```bash
curl http://web01
```

Check log:

```bash
sudo tail -f /var/log/nginx/enterprise_error.log
```

Keyword cần chú ý:

```text
connect() failed
connection refused
upstream
502
```

---

## Case 3: Permission denied khi ghi log

Tạo file log không cho ghi:

```bash
sudo touch /var/log/app.log
sudo chmod 400 /var/log/app.log
```

Nếu app cố ghi vào `/var/log/app.log`, sẽ gặp lỗi permission.

Check:

```bash
journalctl -u fake-app -f
```

Keyword cần chú ý:

```text
Permission denied
```

---

## Case 4: Disk full

Kiểm tra disk:

```bash
df -h
```

Tạo file lớn:

```bash
fallocate -l 5G ~/bigfile.test
```

Kiểm tra lại:

```bash
df -h
```

Xóa sau khi test:

```bash
rm ~/bigfile.test
```

Keyword cần chú ý:

```text
No space left on device
```

---

## Case 5: Database down

Trên `db01`:

```bash
sudo systemctl stop postgresql
```

Check:

```bash
systemctl status postgresql
sudo tail -f /var/log/postgresql/*.log
```

Bật lại:

```bash
sudo systemctl start postgresql
```

Keyword cần chú ý:

```text
connection refused
timeout
database unavailable
```

---

## Case 6: Network không thông

Trên `db01`, chặn port PostgreSQL:

```bash
sudo ufw enable
sudo ufw deny 5432
```

Từ `app01`, test port:

```bash
nc -vz db01 5432
```

Mở lại:

```bash
sudo ufw allow 5432
```

Keyword cần chú ý:

```text
timeout
no route to host
connection refused
```

---

## Case 7: Log rotation

Tạo logrotate config:

```bash
sudo vim /etc/logrotate.d/fake-app
```

Nội dung:

```text
/home/lab/enterprise-lab/logs/app.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
```

Test thử:

```bash
sudo logrotate -d /etc/logrotate.d/fake-app
sudo logrotate -f /etc/logrotate.d/fake-app
```

Xem kết quả:

```bash
ls -lah /home/lab/enterprise-lab/logs/
```

File có thể xuất hiện dạng:

```text
app.log
app.log.1
app.log.2.gz
```

Đọc file `.gz`:

```bash
zgrep ERROR app.log.2.gz
```

---

# 16. Bộ lệnh đọc log enterprise cần luyện

## 16.1. Xem trạng thái service

```bash
systemctl status nginx
systemctl status postgresql
systemctl status fake-app
```

## 16.2. Xem log systemd realtime

```bash
journalctl -u nginx -f
journalctl -u fake-app -f
journalctl -u postgresql -f
```

## 16.3. Xem log gần nhất

```bash
journalctl -u fake-app -n 100 --no-pager
```

## 16.4. Xem log theo thời gian

```bash
journalctl -u fake-app --since "10 minutes ago"
```

```bash
journalctl -u fake-app --since "2026-05-06 09:00:00" --until "2026-05-06 10:00:00"
```

## 16.5. Tìm lỗi trong `/var/log`

```bash
sudo grep -RniE "error|failed|exception|timeout|refused|denied" /var/log 2>/dev/null
```

## 16.6. Theo dõi realtime một file

```bash
tail -f app.log
```

## 16.7. Theo dõi nhiều file

```bash
tail -f /var/log/nginx/*.log
```

## 16.8. Đếm số lỗi

```bash
grep -i error app.log | wc -l
```

## 16.9. Top lỗi xuất hiện nhiều nhất

```bash
grep -iE "error|exception|timeout" app.log | sort | uniq -c | sort -nr
```

---

# 17. Checklist debug enterprise

Khi gặp lỗi, không đọc log lung tung. Đi theo flow:

```text
User request
↓
Nginx / Web server
↓
App server
↓
Database
↓
External service
```

## 17.1. Checklist tầng Web

Trên `web01`:

```bash
systemctl status nginx
sudo nginx -t
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

Cần kiểm tra:

- Nginx có chạy không?
- Config Nginx có lỗi không?
- Request có vào access log không?
- Có lỗi upstream không?
- Status code là 404, 500, 502, 504?

---

## 17.2. Checklist tầng App

Trên `app01`:

```bash
systemctl status fake-app
journalctl -u fake-app -n 100 --no-pager
tail -f /home/lab/enterprise-lab/logs/app.log
```

Cần kiểm tra:

- App service có sống không?
- App có restart liên tục không?
- Có exception không?
- Có timeout không?
- Có permission denied không?
- Có requestId/traceId không?

---

## 17.3. Checklist tầng Database

Trên `db01`:

```bash
systemctl status postgresql
sudo tail -f /var/log/postgresql/*.log
```

Từ `app01` test kết nối:

```bash
nc -vz db01 5432
```

Cần kiểm tra:

- Database có chạy không?
- Port 5432 có mở không?
- App có gọi được DB không?
- DB có log lỗi connection không?

---

## 17.4. Checklist Network

```bash
ping app01
ping db01
nc -vz app01 8080
nc -vz db01 5432
```

Cần kiểm tra:

- Hostname resolve được không?
- Ping được không?
- Port mở không?
- Firewall có chặn không?

---

## 17.5. Checklist Resource

```bash
df -h
free -m
top
htop
```

Cần kiểm tra:

- Disk có đầy không?
- RAM có hết không?
- CPU có cao bất thường không?
- Process có bị kill không?

---

# 18. Lộ trình học 4 tuần

## Tuần 1: Linux log basic

Học:

```text
cat
less
tail
grep
awk
sed
journalctl
systemctl
```

Lab:

```text
Đọc log apt, dpkg, nginx, fake-app
```

---

## Tuần 2: Service debug

Học:

```text
systemd
service start/stop/restart
port
process
permission
```

Lab:

```text
Nginx 502
App chết
Permission denied
Port không mở
```

---

## Tuần 3: Multi-server debug

Học flow:

```text
web01 → app01 → db01
```

Lab:

```text
Nginx gọi app lỗi
App gọi DB lỗi
Firewall chặn port
DNS / hosts sai
```

---

## Tuần 4: Enterprise logging

Học:

```text
requestId
traceId
log rotation
centralized logging
dashboard
alert
```

Có thể cài thêm:

```text
Grafana Loki
Promtail
Prometheus
Grafana
```

---

# 19. Setup tối thiểu nên làm ngay

Nếu muốn nhanh và sát enterprise, làm theo thứ tự:

```text
1. Cài UTM
2. Tạo 3 VM Ubuntu Server:
   - web01
   - app01
   - db01

3. Cài:
   - web01: nginx
   - app01: fake-app service
   - db01: postgresql

4. Cấu hình /etc/hosts để gọi nhau bằng hostname

5. Tạo lỗi:
   - stop app
   - stop db
   - sai port nginx
   - permission denied
   - disk full
   - firewall block

6. Luyện đọc:
   - /var/log/nginx/error.log
   - journalctl -u fake-app
   - /var/log/postgresql/*.log
```

---

# 20. Mindset enterprise cần nhớ

Đọc log không phải là mở file rồi nhìn từng dòng.

Đọc log đúng là:

```text
1. Hiểu flow hệ thống
2. Xác định request đi qua tầng nào
3. Khoanh vùng tầng có lỗi
4. Đọc đúng log của tầng đó
5. Tìm root cause
6. Xác nhận bằng command/service/network/resource
```

Câu hỏi cần tự hỏi khi debug:

```text
1. Service có sống không?
2. Port có mở không?
3. Network có thông không?
4. Log báo lỗi gì?
5. Lỗi xảy ra từ tầng nào?
6. Root cause là service, config, network, database hay resource?
```

---

# 21. Bài tập thực hành

## Bài 1: Nginx 502

Mục tiêu:

```text
Cấu hình Nginx proxy sang app01:8080 nhưng app không chạy.
```

Yêu cầu:

```text
1. Gọi curl từ web01
2. Đọc enterprise_error.log
3. Xác định lỗi
4. Sửa bằng cách chạy app hoặc đổi port đúng
```

---

## Bài 2: App service chết

Mục tiêu:

```text
Stop fake-app rồi kiểm tra log.
```

Command:

```bash
sudo systemctl stop fake-app
systemctl status fake-app
journalctl -u fake-app -n 100 --no-pager
```

Yêu cầu:

```text
1. Xác định service stopped
2. Start lại service
3. Confirm log sinh lại
```

---

## Bài 3: Database down

Mục tiêu:

```text
Stop PostgreSQL trên db01.
```

Command:

```bash
sudo systemctl stop postgresql
systemctl status postgresql
```

Từ app01:

```bash
nc -vz db01 5432
```

Yêu cầu:

```text
1. Xác định port 5432 không kết nối được
2. Start lại PostgreSQL
3. Test lại kết nối
```

---

## Bài 4: Disk full

Mục tiêu:

```text
Giả lập lỗi hết dung lượng disk.
```

Command:

```bash
df -h
fallocate -l 5G ~/bigfile.test
df -h
rm ~/bigfile.test
```

Yêu cầu:

```text
1. Quan sát disk trước và sau
2. Tìm lỗi No space left on device nếu có
3. Xóa file test để phục hồi
```

---

## Bài 5: Log rotation

Mục tiêu:

```text
Rotate app.log thủ công.
```

Command:

```bash
sudo logrotate -d /etc/logrotate.d/fake-app
sudo logrotate -f /etc/logrotate.d/fake-app
ls -lah /home/lab/enterprise-lab/logs/
```

Yêu cầu:

```text
1. Hiểu app.log.1 là gì
2. Hiểu app.log.gz là gì
3. Biết dùng zgrep để đọc log nén
```

---

# 22. Kết luận

Mô hình này đủ để bạn luyện tư duy gần enterprise:

```text
Web Server
↓
Application Server
↓
Database Server
↓
Log / Systemd / Network / Resource
```

Khi đã quen, bạn có thể nâng cấp thêm:

```text
- Docker
- CI/CD
- Prometheus
- Grafana
- Loki
- ELK
- Alertmanager
- Load balancer
- Multiple app instances
```

Đây là nền tảng rất tốt để học Linux, Shell, đọc log, debug production và vận hành hệ thống backend.
