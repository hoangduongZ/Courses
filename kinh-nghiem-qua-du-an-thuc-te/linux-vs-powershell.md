# Linux vs PowerShell — Command Mapping Dictionary

> Từ điển tra cứu nhanh cho Infra/DevOps. Giữ nguyên tên lệnh, không dịch.

---

## 📁 File & Directory Operations

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| List files (basic) | `ls` | `ls` / `Get-ChildItem` / `dir` |
| List files (chi tiết) | `ls -la` | `Get-ChildItem -Force` |
| List đệ quy | `ls -R` | `Get-ChildItem -Recurse` |
| In thư mục hiện tại | `pwd` | `Get-Location` / `pwd` |
| Đổi thư mục | `cd /path/to/dir` | `Set-Location C:\path\to\dir` / `cd` |
| Tạo thư mục | `mkdir -p /path/dir` | `New-Item -ItemType Directory -Path C:\path\dir` / `mkdir` |
| Xóa file | `rm file.txt` | `Remove-Item file.txt` / `rm` |
| Xóa thư mục (đệ quy) | `rm -rf /dir` | `Remove-Item -Recurse -Force C:\dir` |
| Copy file | `cp src.txt dst.txt` | `Copy-Item src.txt dst.txt` / `cp` |
| Copy thư mục | `cp -r /src /dst` | `Copy-Item -Recurse C:\src C:\dst` |
| Move / Rename | `mv old.txt new.txt` | `Move-Item old.txt new.txt` / `mv` |
| Tạo file rỗng | `touch file.txt` | `New-Item file.txt -ItemType File` |
| Xem nội dung file | `cat file.txt` | `Get-Content file.txt` / `cat` |
| Xem n dòng đầu | `head -n 20 file.txt` | `Get-Content file.txt -Head 20` |
| Xem n dòng cuối | `tail -n 20 file.txt` | `Get-Content file.txt -Tail 20` |
| Xem realtime (follow) | `tail -f file.log` | `Get-Content file.log -Wait` |
| Dung lượng file/thư mục | `du -sh /dir` | `Get-ChildItem -Recurse \| Measure-Object -Property Length -Sum` |
| Disk usage tổng thể | `df -h` | `Get-PSDrive` |
| Symlink | `ln -s /src /link` | `New-Item -ItemType SymbolicLink -Path link -Target src` |
| Phân quyền file | `chmod 755 file` | `icacls file /grant User:RX` |
| Đổi owner | `chown user:group file` | `icacls file /setowner "User"` |
| So sánh 2 file | `diff file1 file2` | `Compare-Object (Get-Content f1) (Get-Content f2)` |
| Sync thư mục | `rsync -avz /src/ user@host:/dst/` | `robocopy C:\src C:\dst /E /Z` |
| Sync local (mirror) | `rsync -av --delete /src/ /dst/` | `robocopy C:\src C:\dst /MIR` |

---

## 🔍 Search & Find

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| Tìm file theo tên | `find / -name "*.log"` | `Get-ChildItem -Recurse -Filter "*.log"` |
| Tìm file theo size | `find . -size +100M` | `Get-ChildItem -Recurse \| Where-Object { $_.Length -gt 100MB }` |
| Tìm file sửa gần đây | `find . -mtime -7` | `Get-ChildItem -Recurse \| Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }` |
| Tìm & xóa | `find . -name "*.tmp" -delete` | `Get-ChildItem -Recurse -Filter "*.tmp" \| Remove-Item` |
| Tìm & chạy lệnh | `find . -name "*.sh" -exec chmod +x {} \;` | `Get-ChildItem -Recurse -Filter "*.ps1" \| ForEach-Object { ... }` |
| Grep trong file | `grep "pattern" file.txt` | `Select-String -Pattern "pattern" -Path file.txt` |
| Grep đệ quy | `grep -r "pattern" /dir` | `Get-ChildItem -Recurse \| Select-String "pattern"` |
| Grep case-insensitive | `grep -i "pattern" file` | `Select-String -Pattern "pattern" -Path file -CaseSensitive:$false` |
| Grep + line number | `grep -n "pattern" file` | `Select-String -Pattern "pattern" file` (tự hiện line number) |
| Grep ngược (không chứa) | `grep -v "pattern" file` | `Get-Content file \| Where-Object { $_ -notmatch "pattern" }` |
| Grep chỉ tên file | `grep -rl "pattern" /dir` | `Get-ChildItem -Recurse \| Select-String "pattern" \| Select-Object -ExpandProperty Path -Unique` |
| Which (tìm binary) | `which python` | `Get-Command python` |
| Locate file | `locate filename` | `(Không built-in, dùng Everything hoặc Get-ChildItem)` |
| Tìm trong process list | `ps aux \| grep nginx` | `Get-Process \| Where-Object { $_.Name -like "*nginx*" }` |

---

## 📝 Text Processing

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| In dòng theo pattern | `grep "ERROR" app.log` | `Select-String "ERROR" app.log` |
| Cut cột | `cut -d',' -f1,3 file.csv` | `Import-Csv file.csv \| Select-Object Col1, Col3` |
| Sort | `sort file.txt` | `Get-Content file.txt \| Sort-Object` |
| Unique | `uniq file.txt` | `Get-Content file.txt \| Get-Unique` |
| Sort + Unique | `sort -u file.txt` | `Get-Content file.txt \| Sort-Object -Unique` |
| Count dòng | `wc -l file.txt` | `(Get-Content file.txt).Count` |
| Replace text (in-place) | `sed -i 's/old/new/g' file` | `(Get-Content file) -replace 'old','new' \| Set-Content file` |
| Replace với regex | `sed 's/[0-9]\+/NUM/g' file` | `(Get-Content file) -replace '\d+','NUM' \| Set-Content file` |
| In cột N | `awk '{print $2}' file` | `Get-Content file \| ForEach-Object { ($_ -split '\s+')[1] }` |
| Tính tổng cột | `awk '{sum+=$1} END{print sum}' file` | `(Get-Content file \| ForEach-Object { [double]$_ }) \| Measure-Object -Sum` |
| Append vào file | `echo "text" >> file.txt` | `"text" \| Add-Content file.txt` |
| Ghi đè file | `echo "text" > file.txt` | `"text" \| Set-Content file.txt` |
| Đếm từ | `wc -w file.txt` | `(Get-Content file.txt \| Measure-Object -Word).Words` |
| Head/Tail pipe | `cat file \| head -5` | `Get-Content file \| Select-Object -First 5` |
| Reverse dòng | `tac file.txt` | `[Array]::Reverse($a = Get-Content file.txt); $a` |
| Xóa dòng trống | `grep -v '^$' file` | `Get-Content file \| Where-Object { $_ -ne '' }` |
| Trim whitespace | `sed 's/^[ \t]*//;s/[ \t]*$//' file` | `Get-Content file \| ForEach-Object { $_.Trim() }` |
| Join nhiều file | `cat f1.txt f2.txt > merged.txt` | `Get-Content f1.txt,f2.txt \| Set-Content merged.txt` |

---

## 📊 Log Analysis

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| Xem log realtime | `tail -f /var/log/syslog` | `Get-Content C:\logs\app.log -Wait` |
| Filter ERROR trong log | `grep "ERROR" app.log` | `Select-String "ERROR" app.log` |
| Đếm lần xuất hiện | `grep -c "ERROR" app.log` | `(Select-String "ERROR" app.log).Count` |
| Top 10 IP nhiều nhất | `awk '{print $1}' access.log \| sort \| uniq -c \| sort -rn \| head -10` | `Get-Content access.log \| ForEach-Object { ($_ -split ' ')[0] } \| Group-Object \| Sort-Object Count -Desc \| Select-Object -First 10` |
| Filter theo time range | `awk '$4>="[01/Jan/2024" && $4<="[31/Jan/2024"' access.log` | `Select-String "2024-01" app.log` |
| Extract field cụ thể | `awk -F'"' '{print $2}' access.log` | `Get-Content access.log \| ForEach-Object { ($_ -split '"')[1] }` |
| Log rotate thủ công | `logrotate -f /etc/logrotate.conf` | `(Dùng Task Scheduler + script archive)` |
| Xem system log | `journalctl -xe` | `Get-EventLog -LogName System -Newest 50` |
| Xem event theo ID | `journalctl _PID=1234` | `Get-EventLog -LogName System \| Where-Object { $_.EventID -eq 4625 }` |
| Export log ra file | `journalctl -u nginx > nginx.log` | `Get-EventLog -LogName Application \| Export-Csv events.csv` |

---

## ⚙️ Process Management

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| List process | `ps aux` | `Get-Process` |
| Kill process theo PID | `kill 1234` | `Stop-Process -Id 1234` |
| Kill theo tên | `pkill nginx` | `Stop-Process -Name nginx` |
| Kill force | `kill -9 1234` | `Stop-Process -Id 1234 -Force` |
| Top (realtime) | `top` / `htop` | `Get-Process \| Sort-Object CPU -Descending \| Select-Object -First 20` |
| Background process | `command &` | `Start-Job { command }` |
| List background jobs | `jobs` | `Get-Job` |
| Foreground job | `fg %1` | `Receive-Job -Id 1 -Wait` |
| Kill background job | `kill %1` | `Stop-Job -Id 1` |
| Chạy với priority cao | `nice -n -10 command` | `Start-Process command -Priority High` |
| Xem RAM process | `ps aux --sort=-%mem \| head` | `Get-Process \| Sort-Object WorkingSet64 -Descending \| Select-Object -First 10` |
| Xem file đang mở | `lsof -p 1234` | `(Dùng Sysinternals handle.exe)` |
| Xem port nào chiếm | `lsof -i :8080` | `Get-NetTCPConnection -LocalPort 8080` |

---

## 🌐 Network

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| Ping | `ping host` | `Test-Connection host` |
| Ping n lần | `ping -c 4 host` | `Test-Connection host -Count 4` |
| DNS lookup | `nslookup domain` | `Resolve-DnsName domain` |
| DNS lookup type MX | `nslookup -type=MX domain` | `Resolve-DnsName domain -Type MX` |
| Trace route | `traceroute host` | `Test-NetConnection host -TraceRoute` |
| Port check | `nc -zv host 80` | `Test-NetConnection host -Port 80` |
| Active connections | `ss -tuln` / `netstat -tuln` | `Get-NetTCPConnection` |
| Xem port đang lắng nghe | `ss -tlnp` | `Get-NetTCPConnection -State Listen` |
| Download file | `wget http://url/file` | `Invoke-WebRequest -Uri url -OutFile file` |
| HTTP GET | `curl http://api/endpoint` | `Invoke-RestMethod -Method GET -Uri http://api/endpoint` |
| HTTP POST JSON | `curl -X POST -H "Content-Type: application/json" -d '{"k":"v"}' url` | `Invoke-RestMethod -Method POST -Uri url -Body '{"k":"v"}' -ContentType "application/json"` |
| HTTP với Auth header | `curl -H "Authorization: Bearer TOKEN" url` | `Invoke-RestMethod -Uri url -Headers @{Authorization="Bearer TOKEN"}` |
| HTTP POST form | `curl -X POST -d "user=foo&pass=bar" url` | `Invoke-WebRequest -Method POST -Uri url -Body @{user="foo";pass="bar"}` |
| Check SSL cert | `openssl s_client -connect host:443 \| openssl x509 -noout -dates` | `[Net.ServicePointManager]::SecurityProtocol; (Invoke-WebRequest https://host).RawContent` |
| IP address | `ip addr` / `ifconfig` | `Get-NetIPAddress` |
| Route table | `ip route` | `Get-NetRoute` |
| Firewall status | `ufw status` / `iptables -L` | `Get-NetFirewallRule` |
| Mở port firewall | `ufw allow 8080/tcp` | `New-NetFirewallRule -DisplayName "App" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow` |
| SSH | `ssh user@host` | `ssh user@host` (OpenSSH built-in từ Win10) |
| SSH tunnel | `ssh -L 8080:localhost:80 user@host` | `ssh -L 8080:localhost:80 user@host` |
| SCP | `scp file user@host:/path` | `scp file user@host:/path` (OpenSSH) |

---

## 📦 Package Management

| Mục đích | Linux (apt/Ubuntu) | Linux (yum/RHEL) | PowerShell (winget/choco) |
|---|---|---|---|
| Cài package | `apt install nginx` | `yum install nginx` | `winget install nginx` / `choco install nginx` |
| Gỡ package | `apt remove nginx` | `yum remove nginx` | `winget uninstall nginx` |
| Gỡ + config files | `apt purge nginx` | `yum remove --purge nginx` | `choco uninstall nginx -x` |
| Update packages | `apt update && apt upgrade` | `yum update` | `winget upgrade --all` |
| Search package | `apt search nginx` | `yum search nginx` | `winget search nginx` |
| List installed | `apt list --installed` | `rpm -qa` | `winget list` |
| Info package | `apt show nginx` | `yum info nginx` | `winget show nginx` |
| Check updates available | `apt list --upgradable` | `yum check-update` | `winget upgrade` |

---

## 🗜️ Archive / Compression

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| Nén tar.gz | `tar -czf archive.tar.gz /dir` | `Compress-Archive -Path dir -DestinationPath archive.zip` |
| Giải nén tar.gz | `tar -xzf archive.tar.gz` | `Expand-Archive archive.zip -DestinationPath dir` |
| Giải nén vào thư mục | `tar -xzf archive.tar.gz -C /target` | `Expand-Archive archive.zip -DestinationPath C:\target` |
| Nén zip | `zip -r archive.zip /dir` | `Compress-Archive -Path dir -DestinationPath archive.zip` |
| Giải nén zip | `unzip archive.zip` | `Expand-Archive archive.zip` |
| Xem nội dung tar | `tar -tzf archive.tar.gz` | `(Không built-in, dùng 7zip: 7z l archive.tar.gz)` |
| Nén bzip2 | `tar -cjf archive.tar.bz2 /dir` | `(Không built-in, dùng 7zip)` |
| Nén file đơn (gzip) | `gzip file.txt` | `(Không built-in, dùng 7zip)` |

---

## 🔐 Permission & User Management

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| Whoami | `whoami` | `whoami` / `$env:USERNAME` |
| List users | `cat /etc/passwd` / `getent passwd` | `Get-LocalUser` |
| Tạo user | `useradd -m username` | `New-LocalUser -Name username -NoPassword` |
| Xóa user | `userdel -r username` | `Remove-LocalUser -Name username` |
| Đổi password | `passwd username` | `Set-LocalUser -Name username -Password (Read-Host -AsSecureString)` |
| Thêm vào group | `usermod -aG sudo username` | `Add-LocalGroupMember -Group "Administrators" -Member username` |
| List group của user | `groups username` | `Get-LocalGroupMember -Group "Administrators"` |
| Su / Run as | `sudo command` | `Start-Process powershell -Verb RunAs` |
| Switch user | `su - username` | `runas /user:username cmd` |
| Xem file permission | `ls -la file` | `Get-Acl file` |
| Set permission file | `chmod 755 file` | `icacls file /grant "User:(RX)"` |
| Đổi owner | `chown user:group file` | `icacls file /setowner "User"` |
| Xem sudo rights | `sudo -l` | `(Kiểm tra Local Admin group)` |

### Chmod Quick Reference (Linux)

| Octal | Symbolic | Ý nghĩa |
|---|---|---|
| `777` | `rwxrwxrwx` | Full quyền cho tất cả |
| `755` | `rwxr-xr-x` | Owner full, Others read+exec — chuẩn cho binary/dir |
| `644` | `rw-r--r--` | Owner read+write, Others read-only — chuẩn cho file |
| `600` | `rw-------` | Chỉ owner đọc/ghi — dùng cho SSH private key |
| `400` | `r--------` | Read-only cho owner — credential file |

> Cấu trúc: `[owner][group][others]` — `r=4`, `w=2`, `x=1`

---

## 📋 System Info

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| OS version | `cat /etc/os-release` | `Get-ComputerInfo \| Select-Object OsName, OsVersion` |
| Kernel version | `uname -r` | `(Get-ComputerInfo).OsKernelVersion` |
| Hostname | `hostname` | `hostname` / `$env:COMPUTERNAME` |
| Uptime | `uptime` | `(Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime` |
| CPU info | `lscpu` | `Get-CimInstance Win32_Processor` |
| RAM info | `free -h` | `Get-CimInstance Win32_OperatingSystem \| Select-Object TotalVisibleMemorySize,FreePhysicalMemory` |
| Disk info | `lsblk` / `df -h` | `Get-Disk` / `Get-PSDrive -PSProvider FileSystem` |
| Hardware tổng thể | `dmidecode` | `Get-ComputerInfo` |
| Environment variables | `env` / `printenv` | `Get-ChildItem Env:` |
| Đọc env var cụ thể | `echo $PATH` | `$env:PATH` |
| Set env var (session) | `export VAR=value` | `$env:VAR = "value"` |
| Set env var (permanent) | `echo 'export VAR=val' >> ~/.bashrc` | `[System.Environment]::SetEnvironmentVariable("VAR","val","User")` |
| PATH hiện tại | `echo $PATH` | `$env:PATH` |
| Thêm vào PATH | `export PATH=$PATH:/new/path` | `$env:PATH += ";C:\new\path"` |

---

## 📜 Shell Scripting Essentials

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| Shebang / Script header | `#!/bin/bash` | `# PowerShell script (.ps1)` |
| Biến | `VAR="hello"` | `$var = "hello"` |
| In biến | `echo $VAR` | `Write-Output $var` / `"$var"` |
| If-else | `if [ condition ]; then ... fi` | `if (condition) { ... } else { ... }` |
| If file tồn tại | `if [ -f file.txt ]; then ...` | `if (Test-Path file.txt) { ... }` |
| If thư mục tồn tại | `if [ -d /dir ]; then ...` | `if (Test-Path /dir -PathType Container) { ... }` |
| If string rỗng | `if [ -z "$VAR" ]; then ...` | `if ([string]::IsNullOrEmpty($var)) { ... }` |
| For loop | `for i in 1 2 3; do ... done` | `foreach ($i in 1,2,3) { ... }` |
| For loop range | `for i in {1..10}; do ... done` | `1..10 \| ForEach-Object { ... }` |
| For loop files | `for f in *.txt; do echo $f; done` | `Get-ChildItem *.txt \| ForEach-Object { $_.Name }` |
| While loop | `while [ condition ]; do ... done` | `while (condition) { ... }` |
| Function | `function name() { ... }` | `function Name { param($x) ... }` |
| Return value | `return 0` | `return $value` |
| Exit code | `exit 1` | `exit 1` |
| Check exit code | `if [ $? -eq 0 ]` | `if ($LASTEXITCODE -eq 0)` |
| Read input | `read -p "Prompt: " var` | `$var = Read-Host "Prompt"` |
| Comment | `# comment` | `# comment` |
| Multi-line comment | `: ' ... '` | `<# ... #>` |
| Pipe | `cmd1 \| cmd2` | `cmd1 \| cmd2` |
| Redirect stdout | `cmd > file.txt` | `cmd \| Out-File file.txt` |
| Redirect stderr | `cmd 2> err.txt` | `cmd 2>&1 \| Out-File err.txt` |
| Redirect cả 2 | `cmd > out.txt 2>&1` | `cmd *> out.txt` |
| Null device | `cmd > /dev/null` | `cmd \| Out-Null` |
| String interpolation | `"Hello $VAR"` | `"Hello $var"` |
| Heredoc | `cat << EOF ... EOF` | `@" ... "@ (here-string)` |
| Array | `arr=("a" "b" "c")` | `$arr = @("a","b","c")` |
| Array element | `${arr[0]}` | `$arr[0]` |
| Array length | `${#arr[@]}` | `$arr.Count` |
| HashMap / Dict | `declare -A map; map[key]=val` | `$map = @{key = "val"}` |
| Ternary (inline if) | `VAR=$([ cond ] && echo "yes" \| echo "no")` | `$var = if (cond) { "yes" } else { "no" }` |
| Try-catch | `command \|\| echo "failed"` | `try { ... } catch { Write-Error $_ }` |

### Biến đặc biệt Bash (hay gặp khi đọc script người khác)

| Biến | Ý nghĩa |
|---|---|
| `$0` | Tên script đang chạy |
| `$1`, `$2`, ... | Argument thứ 1, 2, ... truyền vào script |
| `$@` | Tất cả arguments (dạng list) |
| `$#` | Số lượng arguments |
| `$?` | Exit code của lệnh vừa chạy (0 = thành công) |
| `$$` | PID của shell hiện tại |
| `$!` | PID của background process vừa chạy |
| `$_` | Argument cuối cùng của lệnh trước |
| `${VAR:-default}` | Dùng `default` nếu `VAR` chưa set |
| `${VAR:?error}` | Dừng script và báo lỗi nếu `VAR` chưa set |

### Cron Syntax Quick Reference (Linux)

```
* * * * * command
│ │ │ │ │
│ │ │ │ └── Day of week (0=Sun, 7=Sun)
│ │ │ └──── Month (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
```

| Ví dụ | Ý nghĩa |
|---|---|
| `0 2 * * *` | Hàng ngày lúc 02:00 |
| `*/15 * * * *` | Mỗi 15 phút |
| `0 9 * * 1-5` | 9:00 sáng thứ 2-6 |
| `0 0 1 * *` | 0:00 ngày đầu mỗi tháng |
| `@reboot` | Mỗi khi khởi động |
| `@daily` | Tương đương `0 0 * * *` |

---

## ⚙️ Process Management

| Mục đích | Linux (Bash) | PowerShell |
|---|---|---|
| List process | `ps aux` | `Get-Process` |
| Kill process theo PID | `kill 1234` | `Stop-Process -Id 1234` |
| Kill theo tên | `pkill nginx` | `Stop-Process -Name nginx` |
| Kill force | `kill -9 1234` | `Stop-Process -Id 1234 -Force` |
| Top (realtime) | `top` / `htop` | `Get-Process \| Sort-Object CPU -Descending \| Select-Object -First 20` |
| Background process | `command &` | `Start-Job { command }` |
| List background jobs | `jobs` | `Get-Job` |
| Foreground job | `fg %1` | `Receive-Job -Id 1 -Wait` |
| Kill background job | `kill %1` | `Stop-Job -Id 1` |
| Chạy với priority cao | `nice -n -10 command` | `Start-Process command -Priority High` |
| Xem RAM process | `ps aux --sort=-%mem \| head` | `Get-Process \| Sort-Object WorkingSet64 -Descending \| Select-Object -First 10` |
| Xem port nào chiếm | `lsof -i :8080` | `Get-NetTCPConnection -LocalPort 8080` |

---

## 🌿 Git (Common cho Config Management)

| Mục đích | Linux / PowerShell (giống nhau) |
|---|---|
| Clone repo | `git clone https://github.com/user/repo.git` |
| Status | `git status` |
| Stage file | `git add file.txt` / `git add .` |
| Commit | `git commit -m "message"` |
| Push | `git push origin main` |
| Pull | `git pull origin main` |
| Tạo branch | `git checkout -b feature/name` |
| Switch branch | `git checkout main` |
| Merge | `git merge feature/name` |
| Xem log | `git log --oneline --graph` |
| Revert uncommitted | `git checkout -- file.txt` |
| Stash | `git stash` / `git stash pop` |
| Xem diff | `git diff` / `git diff --staged` |
| Tag release | `git tag -a v1.0.0 -m "Release"` |
| Reset về commit trước | `git reset --hard HEAD~1` |

---

## 🐳 Docker (Infra Hiện Đại)

| Mục đích | Command (Linux / PowerShell giống nhau) |
|---|---|
| List container đang chạy | `docker ps` |
| List tất cả container | `docker ps -a` |
| List images | `docker images` |
| Pull image | `docker pull nginx:latest` |
| Chạy container | `docker run -d -p 8080:80 --name web nginx` |
| Stop container | `docker stop web` |
| Start container | `docker start web` |
| Xóa container | `docker rm web` |
| Xóa image | `docker rmi nginx` |
| Exec vào container | `docker exec -it web /bin/bash` |
| Xem logs | `docker logs -f web` |
| Xem resource usage | `docker stats` |
| Build image | `docker build -t myapp:1.0 .` |
| Copy file vào container | `docker cp file.txt web:/path/` |
| Inspect container | `docker inspect web` |
| Docker Compose up | `docker compose up -d` |
| Docker Compose down | `docker compose down` |
| Docker Compose logs | `docker compose logs -f service_name` |
| Prune (dọn dẹp) | `docker system prune -a` |

---

## 🔧 Service Management

| Mục đích | Linux (systemd) | PowerShell (Windows Service) |
|---|---|---|
| Start service | `systemctl start nginx` | `Start-Service nginx` |
| Stop service | `systemctl stop nginx` | `Stop-Service nginx` |
| Restart service | `systemctl restart nginx` | `Restart-Service nginx` |
| Reload config (no restart) | `systemctl reload nginx` | `(Tùy service, thường dùng Restart)` |
| Status service | `systemctl status nginx` | `Get-Service nginx` |
| Enable autostart | `systemctl enable nginx` | `Set-Service nginx -StartupType Automatic` |
| Disable autostart | `systemctl disable nginx` | `Set-Service nginx -StartupType Disabled` |
| List all services | `systemctl list-units --type=service` | `Get-Service` |
| List failed services | `systemctl --failed` | `Get-Service \| Where-Object { $_.Status -eq "Stopped" }` |
| View logs | `journalctl -u nginx -f` | `Get-EventLog -LogName Application -Source nginx -Newest 50` |
| View logs since boot | `journalctl -u nginx -b` | `Get-EventLog -LogName System -After (gcim Win32_OperatingSystem).LastBootUpTime` |

---

## 📅 Scheduling

| Mục đích | Linux | PowerShell |
|---|---|---|
| List scheduled tasks | `crontab -l` | `Get-ScheduledTask` |
| Edit cron | `crontab -e` | `(Dùng Register-ScheduledTask)` |
| Tạo daily task | `0 2 * * * /script.sh` | `Register-ScheduledTask -Action (New-ScheduledTaskAction -Execute 'pwsh' -Argument 'C:\script.ps1') -Trigger (New-ScheduledTaskTrigger -Daily -At 2am) -TaskName "MyTask" -RunLevel Highest` |
| Run at reboot | `@reboot /script.sh` | `-Trigger (New-ScheduledTaskTrigger -AtStartup)` |
| Xóa task | `crontab -r` | `Unregister-ScheduledTask -TaskName "MyTask" -Confirm:$false` |
| Run ngay task | `(chạy script trực tiếp)` | `Start-ScheduledTask -TaskName "MyTask"` |

---

## 💡 Tips & Gotchas

### Pipe: Object vs Text — Điểm khác biệt lớn nhất

```bash
# Bash: pipe truyền TEXT, phải parse thủ công
ps aux | grep nginx | awk '{print $2}'  # lấy PID từ text

# PowerShell: pipe truyền OBJECT, truy cập trực tiếp property
Get-Process | Where-Object { $_.Name -like "*nginx*" } | Select-Object Id
```

### Bash Pitfalls hay gặp

```bash
# Luôn dùng quotes để tránh word splitting
VAR="my file.txt"
rm "$VAR"       # ✅ đúng
rm $VAR         # ❌ sai — hiểu là rm my file.txt (2 file)

# Set -e để script dừng khi có lỗi
#!/bin/bash
set -e          # dừng ngay khi lệnh fail
set -u          # báo lỗi nếu dùng biến chưa khai báo
set -o pipefail # bắt lỗi trong pipe

# Check lệnh tồn tại trước khi dùng
command -v docker &>/dev/null || { echo "docker not found"; exit 1; }
```

### PowerShell Pitfalls hay gặp

```powershell
# Execution Policy — script bị block mặc định
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser  # cho phép chạy script

# Alias behavior khác Bash
# rm trong PS không hỏi confirm mặc định, nhưng Get-ChildItem | rm thì cần -Force
# Khi script production: dùng Remove-Item -Confirm:$false -Force thay vì rm

# $ErrorActionPreference
$ErrorActionPreference = "Stop"  # tương đương set -e trong Bash

# Output vs Return
function Get-Value {
    Write-Output "result"  # đưa vào pipeline
    return "result"        # cũng đưa vào pipeline (PS khác ngôn ngữ khác)
}
```

### Quick Reference: Man page / Help

| Mục đích | Linux | PowerShell |
|---|---|---|
| Xem docs lệnh | `man command` | `Get-Help command -Full` |
| Xem ví dụ | `man command` (xem EXAMPLES) | `Get-Help command -Examples` |
| Tìm lệnh theo từ khóa | `man -k keyword` | `Get-Help *keyword*` |
| Xem tất cả options | `command --help` | `Get-Help command -Parameter *` |

### PowerShell Core (v7+) Cross-Platform

PowerShell 7+ chạy trên Linux/macOS, hỗ trợ hầu hết cmdlet cross-platform. Cài:
```bash
# Ubuntu
sudo apt install powershell
# macOS
brew install powershell
```
Chạy bằng lệnh `pwsh` (không phải `powershell`).
