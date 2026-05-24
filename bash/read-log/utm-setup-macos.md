# Huong dan cai Ubuntu Server tren macOS bang UTM

## 1. Muc tieu

- Cai UTM tren macOS
- Tao VM Ubuntu Server (ARM64 cho Apple Silicon)
- SSH tu macOS vao VM

---

## 2. Tai va cai UTM

- Trang tai: https://mac.getutm.app/
- Tai ban UTM cho macOS, keo vao Applications, mo UTM lan dau va cap quyen can thiet.

---

## 3. Tai ISO Ubuntu Server

- Apple Silicon (M1/M2/M3/M4): Ubuntu Server 24.04 LTS ARM64
- Intel Mac: Ubuntu Server 24.04 LTS AMD64

Goi y: dung ban Server (khong can Desktop) de nhe va sat moi truong that.

---

## 4. Tao VM moi trong UTM

1. Mo UTM -> Create a New Virtual Machine
2. Chon: Virtualize
3. Chon: Linux
4. Chon file ISO Ubuntu Server da tai

---

## 5. Cau hinh VM goi y (Mac M1 Pro 16GB)

Neu tao nhieu VM, giu tong RAM VM 7-9GB de macOS thoai mai.

Goi y cho 1 VM:

- CPU: 1-2 cores
- RAM: 2-3GB
- Disk: 20GB
- Network: Bridged (neu on dinh), neu loi thi chuyen Shared

---

## 6. Cai Ubuntu Server

Trong qua trinh cai dat:

- Hostname: web01 (hoac app01, db01)
- Username: lab
- Password: de nho
- Install OpenSSH Server: YES

---

## 7. Sau khi cai xong

Cap nhat he thong va cai tool co ban:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y vim curl wget net-tools htop tree unzip zip lsof tcpdump rsyslog logrotate
```

Kiem tra IP:

```bash
ip a
# hoac
hostname -I
```

---

## 8. SSH tu macOS vao VM

Tu macOS:

```bash
ssh lab@<IP_VM>
```

Vi du:

```bash
ssh lab@192.168.64.10
```

---

## 9. Tao nhieu VM (tuy chon)

Lap lai cac buoc tren de tao:

- web01
- app01
- db01

Sau do co the chinh hostname:

```bash
sudo hostnamectl set-hostname web01
```

---

## 10. Neu mang Bridged khong on

- Chuyen sang Shared Network trong UTM
- Kiem tra lai IP va SSH

---

## 11. Kiem tra nhanh

```bash
hostname
ip a
systemctl status ssh
```

Neu SSH duoc vao VM va `ssh` service dang chay la on.