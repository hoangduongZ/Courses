# AWS ZERO → HERO (Enterprise) — Task-based Learning Plan

> Mục tiêu tổng: từ nền tảng cloud → thiết kế & triển khai hệ thống AWS production → bảo mật, tối ưu chi phí, vận hành enterprise (IaC, CI/CD, monitoring, DR).
>
> Phạm vi “enterprise cần”: Networking + Security + Compute + Storage + Database + Observability + Automation + Governance + Cost + Resilience.

---

## TASK 01 — AWS Core Concepts & Shared Responsibility
**Mục đích**
- Hiểu đúng ai chịu trách nhiệm cái gì (AWS vs bạn) để thiết kế bảo mật/vận hành đúng.
- Nắm thuật ngữ nền tảng để đọc tài liệu/kiến trúc.

**Keypoint**
- Shared Responsibility Model
- Region / AZ / Edge Locations
- High Availability vs Fault Tolerance vs Disaster Recovery
- Well-Architected Framework 6 pillars (khái niệm, không học thuộc)

---

## TASK 02 — Tạo AWS Account chuẩn enterprise (multi-account mindset)
**Mục đích**
- Tránh “1 account cho tất cả” gây rủi ro bảo mật/chi phí.
- Chuẩn bị nền cho governance.

**Keypoint**
- Root account security (MFA, lock down)
- AWS Organizations (concept), multi-account pattern (prod/stg/dev/logging/security)
- Billing separation, cost allocation tags (concept)
- Baseline guardrails (khái niệm)

---

## TASK 03 — IAM Fundamentals (Identity & Access) — quan trọng nhất
**Mục đích**
- 80% sự cố security đến từ IAM sai.
- Thiết kế quyền đúng: least privilege, audit được.

**Keypoint**
- Users / Groups / Roles / Policies
- Policy evaluation logic (Allow/Deny/Explicit deny)
- IAM role for EC2/Lambda (không dùng access key trong server)
- MFA, access keys rotation
- Permission boundaries (concept) & IAM best practice

---

## TASK 04 — VPC Networking 101 (nền tảng cho mọi kiến trúc)
**Mục đích**
- Hiểu mạng để deploy production an toàn.
- Phân tách public/private, kiểm soát traffic.

**Keypoint**
- VPC, Subnet (public/private), Route Table
- Internet Gateway, NAT Gateway
- Security Group vs NACL
- CIDR planning (tránh overlap)
- Multi-AZ networking basics

---

## TASK 05 — DNS & Traffic Entry: Route 53 + Load Balancing
**Mục đích**
- Đưa traffic vào hệ thống ổn định, scale được.

**Keypoint**
- Route 53 hosted zone, record types (A/AAAA/CNAME/ALIAS)
- Health checks (concept)
- Elastic Load Balancing: ALB vs NLB (khi nào dùng)
- TLS termination, certificates (ACM)

---

## TASK 06 — Compute Basics: EC2 (server truyền thống trên AWS)
**Mục đích**
- Chạy app dạng server/VM, hiểu nền để so sánh với container/serverless.

**Keypoint**
- EC2 instance types (general/compute/memory)
- AMI, EBS, security groups, key pairs
- User data bootstrapping
- Auto Scaling Group (ASG) concept
- Placement across AZ for HA

---

## TASK 07 — Storage Essentials: S3 (trụ cột enterprise)
**Mục đích**
- Lưu object (file, log, backup) an toàn, bền, rẻ.

**Keypoint**
- Buckets, objects, prefixes
- Block public access, bucket policy
- Versioning, lifecycle, storage classes
- SSE-S3 vs SSE-KMS (khái niệm)
- S3 event notifications (concept)

---

## TASK 08 — Block Storage: EBS & Snapshots
**Mục đích**
- Hiểu storage cho EC2/DB, backup đúng cách.

**Keypoint**
- EBS volumes (gp3/io2 concept)
- Snapshots, incremental backups
- Encryption at rest
- Performance basics (IOPS/throughput)

---

## TASK 09 — File Storage: EFS (khi cần shared filesystem)
**Mục đích**
- Chạy workload cần shared files giữa nhiều instance (enterprise hay gặp).

**Keypoint**
- EFS mount targets, security groups
- Performance modes (concept)
- Use-case: uploads, shared assets (cân nhắc S3 trước)

---

## TASK 10 — Database Fundamentals: RDS (managed SQL)
**Mục đích**
- Chạy MySQL/PostgreSQL/Aurora an toàn, backup/HA dễ.

**Keypoint**
- Multi-AZ, read replicas
- Backups, snapshots, maintenance windows
- Parameter groups, subnet groups
- Connection strategy (pooling), security (SG, private subnets)
- Aurora concept (khi nào cân nhắc)

---

## TASK 11 — Caching: ElastiCache (Redis/Memcached)
**Mục đích**
- Giảm tải DB, tăng tốc API, xử lý session/queue.

**Keypoint**
- Redis use-cases: cache, session, locks, queue (pattern)
- Cluster mode concept
- TTL strategy, cache invalidation basics
- Security: private subnet, auth/token (tùy engine)

---

## TASK 12 — Serverless Basics: Lambda + API Gateway
**Mục đích**
- Hiểu serverless để chọn đúng cho enterprise (không phải cái gì cũng Lambda).

**Keypoint**
- Lambda execution model, timeout, memory, cold start concept
- IAM role per function
- API Gateway basics (REST/HTTP)
- Use-case: webhook, small APIs, async processing

---

## TASK 13 — Containers: ECS/Fargate (enterprise phổ biến)
**Mục đích**
- Chạy microservices/container production dễ vận hành hơn EC2 thuần.

**Keypoint**
- ECS concepts: task definition, service, cluster
- Fargate vs EC2 launch type
- ALB integration, autoscaling
- Image registry: ECR
- Secrets/env handling (Secrets Manager/SSM)

---

## TASK 14 — Kubernetes Option: EKS (khi thật sự cần)
**Mục đích**
- Biết khi nào chọn EKS (đắt và phức tạp), tránh overkill.

**Keypoint**
- EKS control plane concept, node groups
- Networking & security overhead
- Operational complexity vs portability benefit
- When not to use EKS

---

## TASK 15 — Infrastructure as Code (IaC): Terraform/CloudFormation/CDK
**Mục đích**
- Enterprise bắt buộc “hạ tầng như code” để audit, rollback, review.

**Keypoint**
- IaC benefits: reproducible, versioned, reviewed
- Terraform vs CloudFormation vs CDK (trade-off)
- State management (Terraform state)
- Environment separation (dev/stg/prod)

---

## TASK 16 — CI/CD on AWS: CodePipeline/CodeBuild/Deploy (hoặc GitHub Actions)
**Mục đích**
- Deploy tự động, an toàn, có rollback.

**Keypoint**
- Build artifacts, container build/push to ECR
- Deploy ECS/ASG strategies
- Blue/green / canary concepts
- Secrets handling in pipeline
- Promotion flow dev→stg→prod

---

## TASK 17 — Observability: CloudWatch (logs/metrics/alarms)
**Mục đích**
- Vận hành enterprise: biết hệ thống đang khỏe hay chết.

**Keypoint**
- CloudWatch Logs, metrics, dashboards
- Alarms, SNS notifications
- Log retention, structured logging
- Basic SLI/SLO mindset (concept)

---

## TASK 18 — Tracing & Audit: X-Ray + CloudTrail
**Mục đích**
- Debug performance distributed và audit ai làm gì trên AWS.

**Keypoint**
- AWS X-Ray (tracing concept)
- CloudTrail (audit events), organization trails concept
- Detective controls vs preventive controls

---

## TASK 19 — Security Services: KMS, Secrets Manager, SSM Parameter Store
**Mục đích**
- Quản lý secrets/keys đúng chuẩn enterprise, tránh hardcode.

**Keypoint**
- KMS basics (CMK concept), encryption at rest
- Secrets Manager rotation concept
- SSM Parameter Store for config
- Least privilege for secret access

---

## TASK 20 — Network Security: WAF, Shield, Security Groups hardening
**Mục đích**
- Bảo vệ hệ thống public-facing trước traffic xấu.

**Keypoint**
- WAF rules (SQLi/XSS managed rules concept)
- Rate limiting, bot control concept
- Shield Standard vs Advanced (concept)
- Security group hygiene

---

## TASK 21 — Backup & Disaster Recovery (DR) Strategy
**Mục đích**
- Enterprise yêu cầu RPO/RTO rõ ràng và có kế hoạch DR.

**Keypoint**
- Backup plans (concept), snapshot strategy
- Multi-AZ vs Multi-Region
- DR patterns: Backup & Restore, Pilot Light, Warm Standby, Active-Active
- Test DR định kỳ

---

## TASK 22 — Cost Management (FinOps mindset)
**Mục đích**
- Tối ưu chi phí cloud là yêu cầu sống còn trong enterprise.

**Keypoint**
- Cost Explorer, Budgets, billing alarms
- Tagging strategy (cost allocation tags)
- Right-sizing EC2/RDS, gp3 tuning
- Reserved Instances/Savings Plans concept
- S3 lifecycle & data transfer costs awareness

---

## TASK 23 — Governance & Compliance (enterprise control plane)
**Mục đích**
- Quản trị tài nguyên, compliance, audit cho tổ chức lớn.

**Keypoint**
- AWS Organizations + SCP (concept)
- Config rules (concept), compliance reporting
- Guardrails & landing zone concept
- Separation of duties (prod access controls)

---

## TASK 24 — Reference Architectures (thực chiến)
**Mục đích**
- Biết ráp kiến trúc đúng cho bài toán doanh nghiệp.

**Keypoint**
- 3-tier web app: ALB + ECS/EC2 + RDS + Redis + S3
- Serverless API: API Gateway + Lambda + DynamoDB/S3
- Batch processing: SQS + workers + scheduled jobs
- Logging pipeline: CloudWatch → S3 → analytics (concept)

---

## TASK 25 — “Hero checklist” (chuẩn năng lực enterprise)
**Mục đích**
- Tự đánh giá đã đủ làm production/lead chưa.

**Keypoint**
- Thiết kế VPC đúng (public/private, NAT, SG)
- IAM least privilege, no hardcoded keys
- Deploy automation bằng IaC + CI/CD
- Observability đầy đủ + alerting
- DR có RPO/RTO + backup test
- Cost controls + tagging + budgets

---

## Suggested learning order (thực tế)
- 2–3 tuần: TASK 01–07 (core + IAM + VPC + S3)
- 3–4 tuần: TASK 06–14 (compute + DB + cache + container/serverless)
- 2–4 tuần: TASK 15–20 (IaC + CI/CD + observability + security)
- Liên tục: TASK 21–25 (DR + cost + governance + kiến trúc)

---