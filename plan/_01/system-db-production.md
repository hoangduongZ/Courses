# Roadmap Kỹ Năng Backend / SRE

---

## 1. System

### Linux nền tảng

- **Process:** PID, signals, systemd, service/unit, journalctl
- **Filesystem:** permissions, ACL cơ bản, inode, symlink, mount, fstab
- **Networking:** DNS, TCP/UDP, ports, iptables/nftables, routing cơ bản
- **Performance:** top/htop, vmstat, iostat, sar, lsof, strace (đủ dùng)
- **Storage:** RAID khái niệm, IO patterns, disk latency, swap, page cache

### Web/App Runtime

- **Reverse proxy:** Nginx (upstream, keepalive, buffering, gzip/brotli, timeouts)
- **JVM basics** (vì bạn dùng Java): heap/metaspace, GC logs, thread dump, OOM, tuning "đủ thực chiến"
- **Containers:** Docker fundamentals, image layering, volumes, networking

### Security Baseline

- TLS/HTTPS, cert lifecycle, HSTS basics
- Secrets management cơ bản (env/secret files), least privilege
- Hardening cơ bản: SSH, firewall, patching, dependency scanning (mức production)

---

## 2. DB (PostgreSQL / Oracle / MySQL — core giống nhau)

### SQL "đủ sâu"

- Joins, window functions, CTE, aggregation đúng
- **Indexing:** B-tree, composite index, covering index, selectivity
- **Query planning:** EXPLAIN / EXPLAIN ANALYZE, hiểu cost, cardinality
- **Transactions:** isolation levels, locks, deadlocks, MVCC
- **Data modeling:** normalization vs denormalization, constraints, FK strategy

### Tối ưu & Vận hành DB

- Slow query diagnosis: top queries, bloat/fragmentation (tuỳ DB)
- Connection pooling: HikariCP/Tomcat pool, max pool sizing theo CPU/DB
- Backups & restore drill: full/incremental, PITR (Postgres), RMAN concept (Oracle)
- Replication/HA: primary-replica, failover concept (ít nhất hiểu vận hành)
- Partitioning (khi data lớn), retention, archiving

### Data Correctness & Safety

- Migration tooling: Flyway/Liquibase (best practice deploy DB)
- Idempotent scripts, rollback plan
- Audit trail, soft delete, data masking/PII basic

---

## 3. Production (SRE/DevOps Mindset)

### Observability

- **Logging:** structured logs, correlation id, log levels, rotation
- **Metrics:** latency, error rate, throughput, saturation (RED/USE)
- **Tracing:** distributed tracing concept (OpenTelemetry level basic)
- **Alerting:** alert "actionable", tránh noise

### Reliability

- SLO/SLI/SLA cơ bản (biết đặt mục tiêu, đo)
- Capacity planning: concurrency, queueing, bottleneck CPU/IO/DB
- Resilience patterns: retry w/ backoff, circuit breaker, rate limit, timeout budget
- Deployment strategies: blue-green / canary / rolling (biết trade-off)
- Incident response: runbook, postmortem, rollback discipline

### CI/CD

- Pipeline: build → test → scan → package → deploy
- Artifact versioning, config separation (dev/stg/prod)
- IaC cơ bản: Docker Compose → (khi lớn) Terraform / Ansible / K8s (học dần)

### Cost / FinOps *(điểm khác biệt lớn)*

- "Cost per request" / per job, right sizing, autoscaling strategy
- DB cost drivers: IOPS, storage, replicas, connection count

---

## 4. "Học là phải có sản phẩm chứng minh"

Làm 2–3 mini project để cover hết các nội dung trên:

### Project 1 — High-load API + DB Tuning

1. API đơn giản + Postgres
2. Tạo data lớn (10–50M rows), đo latency
3. Tối ưu bằng index / partition / cache
4. Viết report: trước/sau (p95, CPU, DB load)

### Project 2 — Production-ready Deployment

1. Dockerfile multi-stage, compose prod
2. Healthcheck + readiness/liveness concept
3. Logging JSON + metrics endpoint
4. Rollback script + runbook

### Project 3 — Incident Simulation

1. Cố tình tạo deadlock / slow query / connection leak
2. Dùng tools để tìm root cause
3. Viết postmortem

---

## 5. Thứ tự học tối ưu *(đỡ lan man)*

| Giai đoạn | Nội dung |
|-----------|----------|
| **1** | Linux + networking + Nginx *(nền vận hành)* |
| **2** | SQL + indexing + transactions + EXPLAIN *(nền DB)* |
| **3** | Observability + pooling + performance testing *(nền production)* |
| **4** | HA/backup/restore + CI/CD + security baseline *(nâng cấp)* |