# 🚀 Lộ trình học DevOps — VPS & AWS theo ràng buộc

> Học đúng thứ tự phụ thuộc = không bị block, không học lại từ đầu.

---

## 🔗 Sơ đồ phụ thuộc tổng thể

```
Linux/SSH/Permissions (nền tảng)
        ↓
  Linux nâng cao (process, systemd, cron, firewall)
        ↓
  Networking cơ bản (DNS, HTTP, TCP/IP, ports)
        ↓
  Nginx cơ bản (serve static, config file, server block)
        ↓
        ├──────────────────────┐
    Docker                  Nginx nâng cao
        ↓                      ↓
  Docker Compose          Reverse proxy, SSL
        ↓                      ↓
        └──────────┬───────────┘
                   ↓
            VPS thực chiến
            (deploy app thật)
                   ↓
            CI/CD (GitHub Actions)
                   ↓
                  AWS
          ┌────────┼────────┐
         EC2     S3/RDS   IAM
                   ↓
              AWS nâng cao
         (VPC, Load Balancer, ECS)
                   ↓
        Infrastructure as Code
              (Terraform)
                   ↓
           Monitoring & Logging
          (Prometheus, Grafana)
```

---

## 🔑 Tầng 1 — Vá lỗ hổng nền tảng (2–3 tuần)

> Ràng buộc cứng nhất. Docker và AWS đều fail âm thầm nếu không hiểu tầng này.

| Thứ tự | Chủ đề | Nội dung | Lý do bắt buộc |
|--------|--------|----------|----------------|
| 1 | **Linux nâng cao** | systemd, journalctl, cron, ufw/iptables, user/group management | Mọi thứ phía sau đều chạy trên Linux |
| 2 | **Networking cơ bản** | DNS, HTTP/HTTPS, TCP/IP, ports, curl, traceroute | Không hiểu network → không debug được bất cứ thứ gì |
| 3 | **Nginx cơ bản** | Install, cấu trúc `nginx.conf`, `server` block, `location` block, serve static files, kiểm tra syntax (`nginx -t`), reload | Nginx nâng cao (reverse proxy, upstream, SSL) là extension — không biết cơ bản thì config sai không debug được |

---

## 🔑 Tầng 2 — Containerization (2–3 tuần)

| Thứ tự | Chủ đề | Nội dung | Lý do bắt buộc |
|--------|--------|----------|----------------|
| 4 | **Docker** | image, container, volume, network, Dockerfile, .dockerignore | AWS ECS/ECR đều dùng Docker — học AWS trước Docker = mù |
| 5 | **Docker Compose** | multi-service, env file, depends_on, health check | Deploy FastAPI + NuxtJS + DB cùng lúc cần cái này |
| 6 | **Nginx nâng cao** | reverse proxy, upstream, SSL/TLS, Let's Encrypt (certbot) | Cần hiểu Docker network trước mới config đúng |

---

## 🔑 Tầng 3 — VPS thực chiến (1–2 tuần)

> Hoàn thành tầng này = đủ năng lực làm việc thực tế với VPS.

| Thứ tự | Chủ đề | Nội dung |
|--------|--------|----------|
| 7 | **Deploy app thật lên VPS** | FastAPI + NuxtJS + Docker Compose + Nginx + SSL end-to-end |
| 8 | **CI/CD với GitHub Actions** | Auto deploy khi push code — cần hiểu SSH + Docker trước |

---

## 🔑 Tầng 4 — AWS (3–4 tuần)

> Học từ gần giống VPS nhất → trừu tượng dần. Không nhảy cóc.

| Thứ tự | Dịch vụ | Nội dung | Lý do thứ tự |
|--------|---------|----------|--------------|
| 9 | **IAM** | users, roles, policies, MFA, least privilege | Bắt buộc đầu tiên — không có IAM không làm được gì trên AWS |
| 10 | **EC2** | instance, security group, key pair, Elastic IP, AMI | Giống VPS nhất — dễ transfer kiến thức |
| 11 | **S3** | bucket, object, policy, versioning, static hosting | Độc lập, dễ học, dùng nhiều nhất |
| 12 | **RDS** | managed database, backup, parameter group, security group | Cần hiểu EC2 networking trước |
| 13 | **VPC** | subnet, route table, NAT gateway, security group vs NACL | Cần hiểu networking tầng 1 + EC2 |
| 14 | **Load Balancer + Auto Scaling** | ALB, target group, launch template, scaling policy | Cần VPC + EC2 vững |
| 15 | **ECS + ECR** | task definition, service, cluster, deploy Docker lên AWS | Cần Docker thành thạo + IAM + VPC |

---

## 🔑 Tầng 5 — Production-grade (tuỳ chọn)

> Áp dụng khi làm dự án lớn hoặc cần scale.

| Chủ đề | Nội dung | Phụ thuộc vào |
|--------|----------|---------------|
| **Terraform** | Infrastructure as Code, state, modules, remote backend | Toàn bộ AWS Tầng 4 |
| **Prometheus + Grafana** | Metrics, alerting, dashboard | App đang chạy thật |
| **EKS** | Kubernetes trên AWS, pod, deployment, service | ECS + Docker thành thạo |

---

## ⚠️ 5 ràng buộc cứng không được phá vỡ

1. **Networking → trước → Docker**
   Docker dùng virtual network. Không hiểu network thật thì debug không được.

2. **Nginx cơ bản → trước → Nginx nâng cao**
   Reverse proxy, upstream, SSL termination là extension của Nginx — không biết `server` block, `location` block thì config sai không biết sai ở đâu.

3. **Docker → trước → AWS ECS/ECR**
   ECS chỉ là Docker được AWS quản lý — thiếu Docker = học ECS như học chữ không có bảng chữ cái.

4. **IAM → trước → mọi thứ trên AWS**
   Không có IAM đúng = security hole hoặc bị khoá toàn bộ tài khoản.

5. **VPS thực chiến → trước → AWS**
   AWS trừu tượng hoá VPS. Hiểu VPS trước thì học AWS nhanh gấp đôi.

---

## ⏱️ Tổng thời gian ước tính

| Kịch bản | Đến VPS thực chiến | Đến AWS cơ bản |
|----------|--------------------|----------------|
| Part-time 2–3h/ngày | ~7–8 tuần | ~4–5 tháng |
| Full-time 6–8h/ngày | ~2–3 tuần | ~6–7 tuần |
| Kết hợp project thật từ Tầng 3 | Lâu hơn 20% | Chắc hơn nhiều |

---

## 📌 Bảng tóm tắt thứ tự bắt buộc

| Tầng | Thứ tự | Chủ đề | Phụ thuộc vào |
|------|--------|--------|---------------|
| 1 | 1 | Linux nâng cao | Linux cơ bản ✅ |
| 1 | 2 | Networking cơ bản | Linux |
| 1 | 3 | **Nginx cơ bản** ← mới | Networking |
| 2 | 4 | Docker | Networking |
| 2 | 5 | Docker Compose | Docker |
| 2 | 6 | Nginx nâng cao | Nginx cơ bản + Docker network |
| 3 | 7 | VPS thực chiến | Docker Compose + Nginx nâng cao |
| 3 | 8 | CI/CD GitHub Actions | SSH + Docker + VPS |
| 4 | 9 | IAM | — (độc lập nhưng bắt buộc đầu tiên) |
| 4 | 10 | EC2 | IAM + Linux + Networking |
| 4 | 11 | S3 | IAM |
| 4 | 12 | RDS | EC2 networking |
| 4 | 13 | VPC | Networking + EC2 |
| 4 | 14 | Load Balancer + Auto Scaling | VPC + EC2 |
| 4 | 15 | ECS + ECR | Docker + IAM + VPC |
| 5 | 16 | Terraform | Toàn bộ AWS Tầng 4 |
| 5 | 17 | Prometheus + Grafana | App đang chạy thật |  
| 5 | 18 | EKS | ECS + Docker thành thạo |

---

*Lộ trình được xây dựng dựa trên mức độ: Linux/SSH/file permissions đã biết. Nginx/Apache chưa config được.*