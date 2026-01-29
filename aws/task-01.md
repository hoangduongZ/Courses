# TASK 01 — AWS Core Concepts & Shared Responsibility (Enterprise)

> Thuộc roadmap: **AWS ZERO → HERO (Enterprise)**  
> Mục tiêu TASK 01: Nắm nền tảng để đọc kiến trúc AWS, hiểu đúng trách nhiệm (AWS vs bạn), chọn đúng khái niệm Region/AZ/Edge, HA/FT/DR, và biết 6 trụ Well-Architected ở mức khái niệm.

---

## 1) Outcome (Definition of Done)
Hoàn thành TASK 01 khi bạn làm được các việc sau:

- [ ] Giải thích **Shared Responsibility Model** bằng ví dụ cho **EC2, S3, RDS, Lambda**.
- [ ] Phân biệt đúng **Region / Availability Zone (AZ) / Edge Location** và tác động tới latency, HA, cost.
- [ ] Phân biệt **High Availability vs Fault Tolerance vs Disaster Recovery** và chọn đúng pattern theo yêu cầu RTO/RPO.
- [ ] Trình bày được **6 pillars** của Well-Architected (ở mức “ý nghĩa / câu hỏi soi lỗi”, không học thuộc chi tiết).

---

## 2) Core Concepts

### 2.1 Shared Responsibility Model (AWS vs Bạn)

**Tóm tắt**
- AWS chịu: **Security OF the Cloud** (hạ tầng vật lý, datacenter, phần cứng, hypervisor, network vật lý…)
- Bạn chịu: **Security IN the Cloud** (cấu hình dịch vụ, IAM, dữ liệu, network logic, OS/app, mã hóa, logging…)

**Cảnh báo enterprise**
- “Dùng managed service” không có nghĩa là “hết trách nhiệm security”.
- Sai IAM / public exposure / thiếu logging vẫn là lỗi của bạn.

#### 2.1.1 Mapping trách nhiệm theo dịch vụ (mẫu chuẩn)
| Service | AWS chịu trách nhiệm chính | Bạn chịu trách nhiệm chính (điểm hay fail) |
|---|---|---|
| **EC2 (VM)** | Datacenter/hardware/hypervisor | OS patching, hardening, SSH keys, Security Group/NACL, app config, data protection, logging/monitoring |
| **S3 (Object storage)** | Durability/availability của storage service | Block public access, bucket policy, encryption, versioning/lifecycle, access logs, data classification |
| **RDS (Managed DB)** | Hạ tầng + phần lớn patching/maintenance engine | Subnet/SG (private), DB users/roles, schema/query, encryption config, backup retention/restore test, audit logs |
| **Lambda (Serverless)** | Runtime infra, scaling nền | IAM role per function, secret handling, input validation, logging/monitoring, timeouts, dependency vulnerabilities |
| **EKS (Managed control plane)** | Control plane | Node security, patching AMI/nodegroup, network policies, RBAC/IAM, container image security |

**Rule-of-thumb**
- Bạn luôn chịu trách nhiệm với: **IAM + Data + Configuration + Monitoring/Audit** (gần như mọi service).

---

### 2.2 Region / AZ / Edge Location

**Region**
- Khu vực địa lý (ví dụ: Singapore, Tokyo…) gồm nhiều AZ.
- Quyết định: **latency**, **data residency/compliance**, **giá**, **dịch vụ có sẵn**.

**Availability Zone (AZ)**
- 1 Region có nhiều AZ, mỗi AZ là 1 cụm datacenter độc lập.
- Dùng **Multi-AZ** để tăng HA (deploy/replicate across AZ).

**Edge Location**
- Hạ tầng gần user (CDN/edge) giúp giảm latency (ví dụ: phân phối nội dung, caching…).
- Thường dùng khi có user phân tán địa lý hoặc cần tăng tốc truy cập.

**Sai lầm thường gặp**
- “Multi-AZ = Multi-Region” ❌ (Multi-AZ vẫn nằm trong 1 Region)
- Chọn Region chỉ vì “nghe quen” ❌ (phải xét latency + compliance + cost + service availability)

---

### 2.3 High Availability vs Fault Tolerance vs Disaster Recovery

**High Availability (HA)**
- Mục tiêu: giảm downtime bằng cách có **redundancy** + **failover**.
- Ví dụ: app chạy 2 AZ + ALB + DB Multi-AZ.

**Fault Tolerance (FT)**
- Mục tiêu: hệ thống vẫn hoạt động **ngay cả khi một phần lỗi**, ít/không gián đoạn.
- Thường đắt/khó hơn HA vì yêu cầu thiết kế “chịu lỗi tức thời” (thường gắn với active-active / đồng bộ).

**Disaster Recovery (DR)**
- Mục tiêu: có kế hoạch phục hồi khi thảm hoạ (mất AZ/Region, mất dữ liệu, lỗi vận hành lớn).
- Khái niệm lõi:
  - **RTO**: thời gian tối đa chấp nhận hệ thống down.
  - **RPO**: dữ liệu tối đa chấp nhận mất.

#### 2.3.1 DR Patterns (nhận biết nhanh)
- **Backup & Restore**: rẻ nhất, RTO/RPO thường lớn.
- **Pilot Light**: giữ nền tảng tối thiểu, scale lên khi có sự cố.
- **Warm Standby**: chạy sẵn bản “nhỏ”, bật full khi có sự cố.
- **Active-Active**: chạy song song 2 nơi, RTO rất thấp, phức tạp và tốn kém.

---

### 2.4 Well-Architected Framework — 6 pillars (khái niệm)
Bạn không cần học thuộc “định nghĩa”, chỉ cần nhớ “đặt câu hỏi soi lỗi”.

1. **Operational Excellence**: vận hành/triển khai có chuẩn không? có runbook, automation, rollback?
2. **Security**: IAM least privilege? encryption? logging/audit? secret handling?
3. **Reliability**: HA/DR? multi-AZ? auto healing? backup/restore test?
4. **Performance Efficiency**: chọn đúng service/size? caching? scale strategy?
5. **Cost Optimization**: right-sizing? lifecycle? budgets/alerts? tránh over-provision?
6. **Sustainability**: tối ưu tài nguyên, giảm lãng phí compute/storage/data transfer.

---

## 3) Mini Labs (không cần tạo AWS account vẫn làm được)

### Lab A — Shared Responsibility Quick Mapping (10 phút)
Điền trách nhiệm cho 4 case sau (viết ngắn gọn 5–7 gạch đầu dòng/case):

- EC2 chạy web app public
- S3 lưu file upload khách hàng
- RDS PostgreSQL chạy production
- Lambda xử lý webhook

> Output: 1 bảng “AWS chịu / Bạn chịu” cho từng case.

---

### Lab B — Region/AZ Decision (10 phút)
Giả sử hệ thống có user chủ yếu ở:
- Việt Nam + Đông Nam Á
- Có yêu cầu dữ liệu không rời khỏi khu vực APAC
- Cần HA trong 1 Region, không yêu cầu multi-region

Trả lời:
- Chọn Region theo tiêu chí nào?
- Multi-AZ triển khai những thành phần nào?
- Edge/CDN có cần không? Khi nào cần?

---

### Lab C — HA vs FT vs DR Scenario (15 phút)
Chọn giải pháp phù hợp cho 3 yêu cầu:

1) Hệ thống nội bộ, chấp nhận downtime 2 giờ, chấp nhận mất dữ liệu 24 giờ  
2) E-commerce, downtime tối đa 15 phút, mất dữ liệu tối đa 5 phút  
3) Payment critical, downtime gần như 0, dữ liệu không được mất

> Output: ghi rõ bạn đang chọn (HA/FT/DR pattern) + lý do theo RTO/RPO.

---

## 4) Checklist “Enterprise mindset” cho TASK 01
- [ ] Không nhầm **Multi-AZ** với **Multi-Region**
- [ ] Luôn tách bạch: **AWS chịu OF** vs **Bạn chịu IN**
- [ ] Nhắc tới RTO/RPO khi nói DR (không nói chung chung)
- [ ] Khi đọc kiến trúc: tự soi theo 6 pillars (security/reliability/cost là 3 trụ hay fail nhất)

---

## 5) Quick Quiz (tự test 5 phút)
1) “S3 bị lộ data do bucket policy public” → lỗi của ai? vì sao?  
2) “EC2 bị hack vì OS không patch” → lỗi của ai?  
3) Multi-AZ giúp gì? không giúp gì?  
4) HA khác FT chỗ nào về cost/complexity?  
5) Bạn kể 6 pillars Well-Architected và 1 câu hỏi soi lỗi cho mỗi pillar.

---

## 6) Deliverable (nộp cuối TASK 01)
Tạo 1 file note (hoặc ngay trong file này) gồm:

- **(A)** Bảng Shared Responsibility cho: EC2/S3/RDS/Lambda (Lab A)
- **(B)** Quyết định Region/AZ/Edge theo scenario (Lab B)
- **(C)** Chọn HA/FT/DR cho 3 yêu cầu có RTO/RPO (Lab C)
- **(D)** 6 pillars + câu hỏi soi lỗi (mỗi pillar 1 câu)

---

## 7) Next (liên kết sang TASK 02)
Sau khi nắm Task 01, bạn sẽ làm Task 02: tạo AWS account theo “enterprise multi-account mindset”
(vì toàn bộ governance/cost/security sau này phụ thuộc nền account setup).

---
