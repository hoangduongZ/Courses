# Giải thích chi tiết: Cấu hình Tomcat & Apache tách biệt

---

## 🔶 PHẦN 1: TOMCAT — CATALINA_BASE vs CATALINA_HOME

### Khái niệm cốt lõi

Tomcat sử dụng **hai biến môi trường** quan trọng:

| Biến | Vai trò | Ví dụ đường dẫn |
|---|---|---|
| `CATALINA_HOME` | Nơi chứa **phần mềm Tomcat gốc** (binary, lib) | `/usr2/tomcat10` |
| `CATALINA_BASE` | Nơi chứa **cấu hình riêng** của instance này | `/usr2/jre/tomcat` |

### Tại sao cần tách ra?

Hãy tưởng tượng bạn có **một bộ phần mềm Tomcat** nhưng muốn chạy **nhiều instance độc lập**:

```
/usr2/tomcat10/          ← CATALINA_HOME (chỉ đọc, không sửa)
  ├── bin/               ← Script khởi động (startup.sh, shutdown.sh)
  ├── lib/               ← Thư viện core của Tomcat

/usr2/jre/tomcat/        ← CATALINA_BASE (cấu hình riêng của bạn)
  ├── conf/              ← Cấu hình server
  ├── logs/              ← Log của instance này
  ├── webapps/           ← Ứng dụng web của instance này
  ├── temp/              ← File tạm
  └── work/              ← File JSP đã compile
```

> **Mục đích:** Nhiều instance Tomcat dùng chung một bộ binary, nhưng mỗi instance có cấu hình, log, app riêng → tiết kiệm dung lượng, dễ quản lý.

### Các bước thực hiện

**Bước 1: Tạo cấu trúc thư mục**
```bash
mkdir -p /usr2/jre/tomcat/{conf,logs,temp,webapps,work}
```

**Bước 2: Sao chép cấu hình mặc định từ Tomcat gốc**
```bash
cp -r /usr2/tomcat10/conf/* /usr2/jre/tomcat/conf/
```
*Lý do copy:* Bạn cần các file như `server.xml`, `web.xml`, `context.xml` làm nền tảng, sau đó chỉnh sửa theo nhu cầu.

**Bước 3: Thiết lập biến môi trường khi khởi động**
```bash
export CATALINA_HOME=/usr2/tomcat10
export CATALINA_BASE=/usr2/jre/tomcat

$CATALINA_HOME/bin/startup.sh   # Tomcat sẽ đọc conf từ CATALINA_BASE
```

**Bước 4: Điều chỉnh `server.xml` theo nhu cầu**
```xml
<!-- /usr2/jre/tomcat/conf/server.xml -->
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

---

## 🔷 PHẦN 2: APACHE — ServerRoot

### Khái niệm cốt lõi

Apache có tham số `ServerRoot` trong `httpd.conf` — đây là **thư mục gốc** mà Apache dùng làm điểm tham chiếu cho tất cả đường dẫn tương đối bên trong cấu hình.

```
/usr2/apache2.4/         ← Apache gốc (binary, lib — không sửa)
  ├── bin/
  └── lib/

/usr2/jre/apache/        ← ServerRoot (cấu hình riêng)
  ├── conf/
  │   └── httpd.conf
  └── logs/
      ├── error.log
      └── access.log
```

### Các bước thực hiện

**Bước 1: Tạo cấu trúc thư mục**
```bash
mkdir -p /usr2/jre/apache/{conf,logs}
```

**Bước 2: Tạo/chỉnh sửa `httpd.conf`**
```apache
# /usr2/jre/apache/conf/httpd.conf

ServerRoot "/usr2/jre/apache"
# Tất cả đường dẫn tương đối bên dưới đều tính từ đây

PidFile    logs/httpd.pid       # → thực tế là /usr2/jre/apache/logs/httpd.pid
ErrorLog   logs/error.log       # → /usr2/jre/apache/logs/error.log
CustomLog  logs/access.log combined

Listen 80

# Tham chiếu đến module của Apache gốc
LoadModule rewrite_module /usr2/apache2.4/modules/mod_rewrite.so
```

**Bước 3: Khởi động Apache với cấu hình riêng**
```bash
/usr2/apache2.4/bin/httpd -f /usr2/jre/apache/conf/httpd.conf -k start
```

> Câu lệnh này nói rõ: *"Dùng binary của Apache gốc, nhưng đọc cấu hình từ thư mục của tôi."*

---

## 🎯 MỤC ĐÍCH TỔNG THỂ

```
                ┌─────────────────────────────────────────┐
                │           HỆ THỐNG CHÍNH                │
                │  /usr2/tomcat10    /usr2/apache2.4       │
                │  (không bao giờ bị sửa đổi)             │
                └────────────┬──────────────┬─────────────┘
                             │              │
                    tham chiếu         tham chiếu
                             │              │
                ┌────────────▼──────────────▼─────────────┐
                │         CẤU HÌNH RIÊNG (JRE)            │
                │  /usr2/jre/tomcat   /usr2/jre/apache     │
                │  (thoải mái sửa, xóa, tạo lại)          │
                └─────────────────────────────────────────┘
```

| Lợi ích | Giải thích |
|---|---|
| **An toàn** | Hệ thống gốc không bao giờ bị ảnh hưởng khi thay đổi cấu hình |
| **Dễ backup** | Chỉ cần backup `/usr2/jre/` là đủ toàn bộ cấu hình |
| **Dễ rollback** | Nếu cấu hình lỗi, xóa thư mục jre và tạo lại từ đầu |
| **Chạy nhiều instance** | Có thể tạo `/usr2/jre2/tomcat`, `/usr2/jre3/tomcat`... dùng chung binary |
| **Không xung đột** | Mỗi môi trường (dev, staging, prod) có cấu hình độc lập |

---

## 📝 TÓM TẮT NHANH

> **CATALINA_BASE (Tomcat)** và **ServerRoot (Apache)** đều có cùng mục đích:
> Tách **cấu hình riêng** ra khỏi **phần mềm gốc**, để có thể thoải mái chỉnh sửa cấu hình mà **không ảnh hưởng đến hệ thống chính**.

Phần mềm gốc (`/usr2/tomcat10`, `/usr2/apache2.4`) chỉ được **tham chiếu đến**, không bị sửa đổi. Còn toàn bộ cấu hình, log, app đều nằm gọn trong `/usr2/jre/tomcat` và `/usr2/jre/apache`.