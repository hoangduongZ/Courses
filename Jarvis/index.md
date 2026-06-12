# Jarvis Agent — Lộ trình & Kiến trúc

> Xây dựng personal AI agent: giám sát hệ thống chủ động + nhận lệnh qua Telegram + thực thi trên máy tính tại nhà.

---

## Bức tranh tổng thể

```
┌─────────────────────────────────────────────────────────────────┐
│                    MÁY TÍNH TẠI NHÀ                             │
│  CPU/RAM   Docker containers   Logs   HTTP endpoints            │
│      └──────────┴──────────────┴──────────┘                     │
│                       Metrics collector                          │
│                    (agent nhỏ chạy nền)                         │
└─────────────────────────┬───────────────────────────────────────┘
                          │ HTTPS / SSH tunnel
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                     VPS — NÃO TRUNG TÂM                         │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Monitor loop (APScheduler — mỗi 30s–5m)                 │    │
│  │   Rule engine → nếu có bất thường → gọi Claude          │    │
│  └───────────────────────┬─────────────────────────────────┘    │
│                          │                                       │
│  ┌───────────────────────▼─────────────────────────────────┐    │
│  │ Claude API                                               │    │
│  │   Đọc metrics + log đã lọc → phân tích nguyên nhân      │    │
│  │   → viết alert human-readable + đề xuất action          │    │
│  └───────────────────────┬─────────────────────────────────┘    │
│                          │                                       │
│  ┌───────────────────────▼─────────────────────────────────┐    │
│  │ FastAPI                                                  │    │
│  │   Webhook receiver (nhận lệnh từ Telegram)               │    │
│  │   Alert pusher (chủ động gửi ra Telegram)                │    │
│  └───────────────────────┬─────────────────────────────────┘    │
│                          │                                       │
│  ┌───────────────────────▼─────────────────────────────────┐    │
│  │ Tool executor                                            │    │
│  │   SSH exec → máy nhà     run_shell → VPS                 │    │
│  │   send_email             restart_service                 │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                ┌─────────▼─────────┐
                │   Telegram Bot    │
                │  push alert ↑     │
                │  nhận lệnh ↓      │
                └─────────┬─────────┘
                          │
                ┌─────────▼─────────┐
                │      Bạn          │
                │  điện thoại bất   │
                │  cứ đâu           │
                └───────────────────┘
```

---

## Hai chế độ hoạt động

### Proactive — agent tự chạy nền, không cần bạn làm gì

| Trigger | Điều kiện | Alert nội dung |
|---------|-----------|----------------|
| CPU cao | > 90% liên tục 5 phút | Process nào gây ra, đề xuất kill/restart |
| Container down | exit code != 0 | 20 dòng log cuối, đề xuất restart |
| Disk gần đầy | > 85% | Thư mục nào chiếm nhiều, đề xuất rotate log |
| HTTP endpoint fail | 3 lần liên tiếp | Service nào, last successful request lúc nào |
| Anomaly | CPU/RAM tăng đột biến so với baseline | So sánh với 24h trước |

### Reactive — bạn ra lệnh, agent thực thi

```
Bạn: "restart api-server"
Jarvis: SSH → docker compose restart api → "Done. Container healthy, uptime 0:00:12"

Bạn: "show log lỗi lúc nãy"  
Jarvis: tail log → Claude tóm tắt → "NullPointerException tại line 142, xảy ra 3 lần từ 03:40"

Bạn: "disk đang thế nào"
Jarvis: df -h + du → "Tổng 87% — /var/log chiếm 12GB, rotate ngay?"

Bạn: "deploy branch feature/payment"
Jarvis: git pull → docker build → docker compose up → health check → báo cáo
```

---

## Lộ trình học theo ràng buộc

### Tầng 1 — Nền tảng bắt buộc (2–3 tuần)

> Không có tầng này, mọi thứ phía sau đều fail im lặng.

| Thứ tự | Công nghệ | Cần học gì | Lý do ràng buộc |
|--------|-----------|------------|-----------------|
| 1 | **Python cơ bản** | functions, modules, venv, pip, error handling | Toàn bộ stack là Python |
| 2 | **Linux + SSH** | systemd, cron, ufw, user/group, journalctl | Agent chạy trên Linux, SSH để vào máy nhà |
| 3 | **Networking** | HTTP/HTTPS, TCP/IP, ports, curl | Không hiểu network → không debug được webhook, tunnel |

### Tầng 2 — Python nâng cao + async (1–2 tuần)

| Thứ tự | Công nghệ | Cần học gì | Lý do ràng buộc |
|--------|-----------|------------|-----------------|
| 4 | **FastAPI** | route, request, response, middleware, background tasks | Backend nhận webhook + push alert |
| 5 | **asyncio cơ bản** | async/await, event loop, concurrent tasks | Monitor loop + webhook server chạy song song |
| 6 | **APScheduler** | interval job, cron job, chạy nền | Monitor loop cần scheduler, không phải vòng lặp while |

### Tầng 3 — Claude API + Agent pattern (1–2 tuần)

> Đây là não của Jarvis.

| Thứ tự | Công nghệ | Cần học gì | Lý do ràng buộc |
|--------|-----------|------------|-----------------|
| 7 | **Claude Messages API** | gọi API, parse response, handle lỗi, retry | Gọi được API trước mới học tool_use |
| 8 | **Tool use / Function calling** | định nghĩa tool schema, parse `tool_use` block, execute → trả kết quả | Cơ chế để Claude quyết định action nào |
| 9 | **Prompt engineering** | system prompt rõ ràng, context window management, chỉ đưa log đã lọc | Token tốn hay không phụ thuộc vào cái này |

### Tầng 4 — Execution layer (1–2 tuần)

| Thứ tự | Công nghệ | Cần học gì | Lý do ràng buộc |
|--------|-----------|------------|-----------------|
| 10 | **subprocess** | `run()`, `Popen`, capture output, timeout, KHÔNG dùng `shell=True` bừa | Chạy shell command an toàn trên VPS |
| 11 | **Paramiko (SSH)** | connect, exec_command, SFTP, key-based auth | SSH vào máy nhà để thực thi lệnh |
| 12 | **Docker SDK for Python** | list containers, start/stop/restart, logs, stats | Quản lý Docker không cần SSH cho các tác vụ đơn giản |
| 13 | **psutil** | cpu_percent, memory, disk, process list | Thu thập metrics từ máy nhà |

### Tầng 5 — Telegram interface (3–5 ngày)

| Thứ tự | Công nghệ | Cần học gì | Lý do ràng buộc |
|--------|-----------|------------|-----------------|
| 14 | **python-telegram-bot** | Bot token, webhook setup, sendMessage, inline keyboard | Interface duy nhất bạn tương tác với Jarvis |
| 15 | **Telegram webhook vs polling** | Webhook cần HTTPS + domain, polling dùng khi dev local | Cần hiểu để setup đúng trên VPS |

### Tầng 6 — Deploy & vận hành (1 tuần)

| Thứ tự | Công nghệ | Cần học gì | Lý do ràng buộc |
|--------|-----------|------------|-----------------|
| 16 | **Docker + Docker Compose** | Dockerfile, multi-service, volume, network | Package toàn bộ stack, restart policy |
| 17 | **Nginx + SSL** | reverse proxy tới FastAPI, Let's Encrypt | Telegram webhook bắt buộc HTTPS |
| 18 | **Reverse SSH tunnel** | `ssh -R`, autossh, chạy khi máy nhà khởi động | Máy nhà không cần IP public vẫn kết nối được VPS |
| 19 | **systemd service** | unit file, restart=always, journalctl | Jarvis phải chạy 24/7, tự restart khi crash |

### Tầng 7 — Nâng cao (tuỳ chọn)

| Công nghệ | Mục đích | Phụ thuộc vào |
|-----------|----------|---------------|
| **Prometheus + Grafana** | Visualize metrics, lịch sử dài hạn | Tầng 4 + 6 |
| **Redis** | Cache metrics, rate limiting alert (không spam) | Tầng 2 |
| **SQLite / PostgreSQL** | Lưu lịch sử alert, audit log | Tầng 2 |
| **Tailscale** | Thay thế reverse SSH tunnel, dễ hơn nhiều | Tầng 1 |

---

## Ràng buộc cứng không được phá vỡ

1. **Python → trước → mọi thứ**
   Toàn bộ stack viết bằng Python. Không thể học FastAPI hay Paramiko khi chưa hiểu Python.

2. **Linux + SSH → trước → Paramiko + systemd**
   Paramiko là SSH bằng code. Không biết SSH tay thì không debug được khi Paramiko fail.

3. **Claude API cơ bản → trước → Tool use**
   Tool use là extension của Messages API. Không hiểu request/response cơ bản thì parse `tool_use` block không được.

4. **subprocess/Paramiko → trước → Tool executor**
   Tool executor chỉ là wrapper gọi subprocess/Paramiko. Cần hiểu từng thứ riêng trước.

5. **FastAPI + asyncio → trước → chạy monitor loop + webhook song song**
   Monitor loop và webhook server phải chạy đồng thời. Không hiểu async thì hai cái này block nhau.

6. **Docker + Nginx + SSL → trước → deploy lên VPS**
   Telegram bắt buộc HTTPS. Không có SSL thì webhook không đăng ký được.

7. **Rule engine → xử lý trước → mới gọi Claude**
   Claude chỉ được gọi khi rule engine xác nhận có vấn đề. Gọi Claude mỗi 30 giây = tốn tiền vô nghĩa.

---

## Ước tính chi phí vận hành

| Thành phần | Chi phí |
|-----------|---------|
| VPS (2GB RAM) | $5–6/tháng |
| Claude API (hệ thống ổn định) | ~$1–2/tháng |
| Claude API (hệ thống hay lỗi) | ~$5–10/tháng |
| Telegram Bot | Miễn phí |
| **Tổng** | **~$6–16/tháng** |

---

## Thứ tự build thực tế

Không build hết một lúc — build từng layer, test chạy được rồi mới thêm:

```
Bước 1: Python script đọc CPU/RAM + in ra terminal
         ↓
Bước 2: Gửi Telegram message khi CPU > 90%
         ↓
Bước 3: Telegram bot nhận lệnh, reply cứng "pong"
         ↓
Bước 4: Kết nối Claude API, relay lệnh từ Telegram → Claude → reply
         ↓
Bước 5: Thêm tool run_shell, test trên VPS
         ↓
Bước 6: Thêm Paramiko, SSH vào máy nhà chạy lệnh đơn giản
         ↓
Bước 7: Monitor loop chạy nền, push alert khi có vấn đề
         ↓
Bước 8: Docker hoá, deploy lên VPS, cấu hình systemd
         ↓
Bước 9: Reverse SSH tunnel từ máy nhà → VPS
         ↓
Bước 10: Thêm tool theo nhu cầu thực tế
```

---

## Stack tóm tắt

```
Language        Python 3.11+
Web framework   FastAPI + uvicorn
Scheduler       APScheduler
LLM             Claude API (claude-sonnet-4-20250514)
SSH client      Paramiko
Metrics         psutil + Docker SDK
Telegram        python-telegram-bot
Container       Docker + Docker Compose
Reverse proxy   Nginx + Let's Encrypt
Tunnel          autossh (reverse SSH) hoặc Tailscale
Process mgmt    systemd
```

---

*Thiết kế dựa trên nguyên tắc: Claude là bước cuối — nhận data đã lọc, viết summary, đề xuất action. Rule engine xử lý 90% logic phân loại. Token tốn thấp, latency thấp.*