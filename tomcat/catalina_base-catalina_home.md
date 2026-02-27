# Kiến thức về Apache Tomcat: CATALINA_HOME vs CATALINA_BASE

Tài liệu này giải thích sự khác biệt giữa hai biến môi trường quan trọng nhất trong việc quản lý và triển khai Apache Tomcat chuyên nghiệp.

---

## 1. Định nghĩa & So sánh

| Biến môi trường | Ý nghĩa | Nội dung bên trong |
| :--- | :--- | :--- |
| **CATALINA_HOME** | Đường dẫn đến **thư mục cài đặt gốc** của Tomcat. | Chứa các file thực thi, thư viện dùng chung (`bin`, `lib`). |
| **CATALINA_BASE** | Đường dẫn đến **instance (phiên bản chạy)** cụ thể. | Chứa cấu hình và dữ liệu của từng project (`conf`, `webapps`, `logs`, `temp`, `work`). |



---

## 2. Mục đích của việc tách biệt

Mục đích chính là thực hiện mô hình **"Một bộ cài - Nhiều ứng dụng"** (One installation - Multiple instances).

* **Dễ dàng nâng cấp:** Khi cần cập nhật phiên bản Tomcat, bạn chỉ cần thay đổi thư mục `CATALINA_HOME`. Toàn bộ code và cấu hình trong `CATALINA_BASE` của từng dự án vẫn giữ nguyên.
* **Quản lý độc lập:** Mỗi dự án có thể được khởi động, dừng, hoặc cấu hình bộ nhớ (JVM Heap size) và cổng (Port) hoàn toàn riêng biệt.
* **Tăng tính bảo mật:** Có thể thiết lập quyền "Chỉ đọc" (Read-only) cho thư mục `CATALINA_HOME` để tránh việc ứng dụng web can thiệp vào mã nguồn gốc của server.
* **Gọn gàng:** Tránh việc để lẫn lộn file log và file tạm của nhiều dự án vào chung một chỗ.

---

## 3. Cấu trúc thư mục tiêu chuẩn

Khi tách biệt, cấu trúc thư mục thường trông như sau:

### Thư mục gốc (`CATALINA_HOME`)
Dùng chung cho toàn bộ server:
* `bin/`: Chứa các script khởi động (`startup.sh`, `catalina.sh`).
* `lib/`: Chứa các thư viện JAR cốt lõi của Tomcat.

### Thư mục Instance (`CATALINA_BASE`)
Mỗi dự án sẽ có một thư mục riêng:
* `conf/`: Chứa `server.xml`, `web.xml` (Cấu hình Port, Context...).
* `webapps/`: Chứa file `.war` hoặc thư mục code của ứng dụng.
* `logs/`: Lưu log riêng của ứng dụng đó.
* `temp/` & `work/`: Các file tạm và file compiled JSP.

---

## 4. Cách triển khai thực tế (Ví dụ trên Linux)

Để chạy một Project A với một `CATALINA_BASE` riêng, bạn thực hiện các bước sau:

1.  **Tạo thư mục cho Project A:** Copy các thư mục `conf`, `webapps`, `logs`, `temp`, `work` từ Tomcat gốc sang thư mục mới (vd: `/opt/project_A`).
2.  **Cấu hình Port:** Sửa file `/opt/project_A/conf/server.xml` (HTTP port, Shutdown port, AJP port) để không trùng với instance khác.
3.  **Khởi chạy bằng Script:**

```bash
# 1. Thiết lập đường dẫn bộ cài gốc
export CATALINA_HOME=/usr2/jre/tomcat

# 2. Thiết lập đường dẫn cho project cụ thể
export CATALINA_BASE=/opt/project_A

# 3. Chạy Tomcat instance này
$CATALINA_HOME/bin/catalina.sh start
```

---

## 5. So sánh với Apache ServerRoot

`CATALINA_BASE` (Tomcat) và `ServerRoot` (Apache) đều có cùng mục đích:

* Tách cấu hình ra khỏi phần mềm gốc, để có thể thoải mái chỉnh sửa mà không ảnh hưởng đến hệ thống chính.
* Phần mềm gốc (`/usr2/tomcat10`, `/usr2/apache2.4`) chỉ được tham chiếu đến, không bị sửa đổi. Toàn bộ cấu hình, log và ứng dụng được đặt riêng trong `/usr2/jre/tomcat` và `/usr2/jre/apache`.

