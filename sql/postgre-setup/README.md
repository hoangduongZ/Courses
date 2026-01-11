# PostgreSQL với Docker Compose

## Khởi động

```bash
cd /Users/macbook/Documents/Course/sql/postgre-setup
docker-compose up -d
```

## Thông tin kết nối

### PostgreSQL Database
- **Host:** localhost
- **Port:** 5432
- **Database:** mydb
- **Username:** postgres
- **Password:** MyStrongPassword123

### pgAdmin (Web UI)
- **URL:** http://localhost:5050
- **Email:** admin@admin.com
- **Password:** admin123

## Kết nối nhanh

### Từ terminal (psql)
```bash
# Kết nối vào container
docker exec -it postgres-db psql -U postgres -d mydb

# Hoặc từ máy host (nếu đã cài psql)
psql -h localhost -p 5432 -U postgres -d mydb
```

### Các lệnh SQL cơ bản
```sql
-- Xem danh sách databases
\l

-- Kết nối sang database khác
\c demo_db

-- Xem danh sách tables
\dt

-- Xem cấu trúc table
\d employees

-- Query dữ liệu
SELECT * FROM employees;

-- Thoát
\q
```

## Quản lý

### Xem logs
```bash
docker-compose logs -f postgres-db
```

### Dừng services
```bash
docker-compose stop
```

### Khởi động lại
```bash
docker-compose start
```

### Xóa tất cả (cẩn thận - mất data!)
```bash
docker-compose down -v
```

### Backup database
```bash
# Backup
docker exec -t postgres-db pg_dump -U postgres mydb > backup.sql

# Restore
docker exec -i postgres-db psql -U postgres mydb < backup.sql
```

## So sánh PostgreSQL vs Oracle

| Tính năng | PostgreSQL | Oracle |
|-----------|-----------|---------|
| Dung lượng image | ~80MB | ~3.7GB |
| Thời gian khởi động | ~5 giây | ~3-5 phút |
| Miễn phí | ✅ Hoàn toàn | ❌ Chỉ XE (giới hạn) |
| Performance | Rất tốt | Xuất sắc |
| Phổ biến | #4 thế giới | #1 thế giới |
| Học tập | Dễ hơn | Phức tạp hơn |
