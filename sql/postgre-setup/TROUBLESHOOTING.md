# Khắc phục lỗi Docker pull chậm/treo

## Vấn đề

Khi chạy lệnh `docker pull` hoặc `docker-compose up`, quá trình download image bị treo rất lâu hoặc không thể kết nối:

```bash
docker pull postgres:16-alpine
# Bị treo ở "Waiting..." hoặc "Pulling..."
```

```bash
docker-compose up -d
# Pulling rất lâu, hàng chục phút mà không xong
```

### Nguyên nhân

1. **Docker Hub bị chặn hoặc chậm**: 
   - Docker Hub (registry-1.docker.io) có thể bị chặn bởi firewall/ISP
   - Kết nối từ một số khu vực địa lý đến Docker Hub rất chậm
   - Bandwidth hạn chế hoặc rate limiting

2. **Kiểm tra kết nối**:
```bash
ping -c 3 registry-1.docker.io
# Kết quả: 100% packet loss hoặc timeout
```

## Giải pháp: Cấu hình Docker Registry Mirrors

### Bước 1: Tạo file cấu hình Docker daemon

Registry mirrors là các server sao chép (mirror) của Docker Hub, thường nhanh hơn cho khu vực địa lý cụ thể.

```bash
# Tạo thư mục cấu hình (nếu chưa có)
mkdir -p ~/.docker

# Tạo file cấu hình daemon.json
cat > ~/.docker/daemon.json << 'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.gcr.io"
  ]
}
EOF
```

### Bước 2: Restart Docker

**Với OrbStack (macOS):**
```bash
# Đóng OrbStack
osascript -e 'quit app "OrbStack"'

# Đợi 3 giây
sleep 3

# Mở lại OrbStack
open -a OrbStack

# Đợi 5 giây để khởi động
sleep 5
```

**Với Docker Desktop (macOS):**
```bash
osascript -e 'quit app "Docker"'
sleep 3
open -a Docker
sleep 10
```

**Với Docker Engine (Linux):**
```bash
sudo systemctl restart docker
```

### Bước 3: Kiểm tra cấu hình

```bash
# Xem file cấu hình
cat ~/.docker/daemon.json

# Kiểm tra Docker đã hoạt động chưa
docker version

# Thử pull image
docker pull postgres:16-alpine
```

## Registry Mirrors được khuyến nghị

### Cho khu vực Châu Á / Việt Nam:

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.gcr.io",
    "https://dockerproxy.com"
  ]
}
```

### Cho khu vực Trung Quốc:

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://registry.docker-cn.com",
    "https://docker.m.daocloud.io"
  ]
}
```

### Cho khu vực Quốc tế:

```json
{
  "registry-mirrors": [
    "https://mirror.gcr.io",
    "https://dockerproxy.com"
  ]
}
```

## Kết quả sau khi áp dụng

**Trước khi cấu hình:**
```bash
docker pull postgres:16-alpine
# Treo 10+ phút, không download được
```

**Sau khi cấu hình:**
```bash
docker pull postgres:16-alpine
# Download xong trong 15-30 giây
```

```bash
docker-compose up -d
# PostgreSQL khởi động thành công trong 6 giây
```

## Các lệnh hữu ích

### Kiểm tra Docker registry đang dùng:
```bash
docker info | grep -A 5 "Registry Mirrors"
```

### Xem logs khi pull image:
```bash
docker pull postgres:16-alpine --debug
```

### Test speed của các mirrors:
```bash
# Mirror 1
time curl -I https://docker.mirrors.ustc.edu.cn/v2/

# Mirror 2
time curl -I https://hub-mirror.c.163.com/v2/
```

### Xóa bỏ cấu hình mirrors:
```bash
rm ~/.docker/daemon.json
# Sau đó restart Docker
```

## Giải pháp thay thế

### 1. Sử dụng VPN
Nếu Docker Hub bị chặn hoàn toàn, sử dụng VPN để kết nối:
- WireGuard
- OpenVPN
- Tailscale

### 2. Download image từ nguồn khác
```bash
# GitHub Container Registry
docker pull ghcr.io/postgres/postgres:16-alpine

# Quay.io
docker pull quay.io/postgres/postgres:16-alpine
```

### 3. Build image locally
Nếu có Dockerfile, build trực tiếp thay vì pull:
```bash
docker build -t my-postgres .
```

## Tham khảo

- [Docker Registry Mirrors Documentation](https://docs.docker.com/registry/recipes/mirror/)
- [Docker Daemon Configuration](https://docs.docker.com/engine/reference/commandline/dockerd/)
- [USTC Docker Mirror](https://mirrors.ustc.edu.cn/help/dockerhub.html)

## Lưu ý

- Registry mirrors chỉ hỗ trợ **public images** (image công khai)
- **Private images** vẫn phải pull trực tiếp từ registry gốc
- Nên dùng nhiều mirrors để fallback khi một mirror bị lỗi
- Mirrors có thể không sync real-time (delay vài giờ)
