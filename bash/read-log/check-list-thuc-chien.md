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