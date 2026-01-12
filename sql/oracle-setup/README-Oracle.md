# Oracle Database với Docker Compose

## Cài đặt và khởi chạy

### 1. Khởi động Oracle Database
```bash
cd /Users/macbook/Documents/Course/sql
docker-compose up -d
```

### 2. Kiểm tra logs
```bash
docker-compose logs -f oracle-db
```

Chờ khoảng 3-5 phút để Oracle Database khởi động hoàn tất. Bạn sẽ thấy message "DATABASE IS READY TO USE!"

### 3. Kết nối đến Oracle Database

**Thông tin kết nối:**
- **Hostname:** localhost
- **Port:** 1521
- **SID:** XE
- **PDB:** XEPDB1
- **Username:** system hoặc sys
- **Password:** MyStrongPassword123 (có thể thay đổi trong file .env)
- **Enterprise Manager:** http://localhost:5500/em

### 4. Kết nối bằng SQL*Plus (từ bên trong container)
```bash
docker exec -it oracle-xe sqlplus system/MyStrongPassword123@XE
```

hoặc kết nối đến PDB:
```bash
docker exec -it oracle-xe sqlplus system/MyStrongPassword123@XEPDB1
```

### 5. Kết nối bằng SQL client khác
- **DBeaver:** jdbc:oracle:thin:@localhost:1521:XE
- **SQL Developer:** localhost:1521:XE
- **SQLcl, DataGrip, etc.**

## Quản lý Database

### Dừng database
```bash
docker-compose stop
```

### Khởi động lại
```bash
docker-compose start
```

### Xóa database và data (cẩn thận!)
```bash
docker-compose down -v
```

### Xem resource usage
```bash
docker stats oracle-xe
```

## Tạo User mới

```sql
-- Kết nối vào PDB
ALTER SESSION SET CONTAINER = XEPDB1;

-- Tạo user mới
CREATE USER myuser IDENTIFIED BY mypassword;

-- Cấp quyền
GRANT CONNECT, RESOURCE TO myuser;
GRANT CREATE SESSION TO myuser;
GRANT UNLIMITED TABLESPACE TO myuser;

-- Hoặc cấp quyền DBA (cho dev/testing)
GRANT DBA TO myuser;
```

## Scripts khởi tạo

Đặt các file .sql vào thư mục `init-scripts/` để tự động chạy khi database khởi động lần đầu.

## Lưu ý
- Lần đầu pull image có thể mất thời gian (khoảng 2-3GB)
- Database cần ít nhất 2GB RAM để chạy tốt
- Data được lưu trong Docker volume `oracle-data`
- Đổi mật khẩu trong file `.env` trước khi deploy production
