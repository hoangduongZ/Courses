# Kiến thức common PowerShell để đọc hiểu lệnh thay vì học vẹt

> Mục tiêu của tài liệu này:  
> Không học PowerShell bằng cách nhớ từng lệnh rời rạc, mà học theo **ngôn ngữ thiết kế** của PowerShell để nhìn một lệnh lạ vẫn có thể đoán được nó đang làm gì.

---

## 0. Một câu chốt để nhớ

PowerShell không được thiết kế chủ yếu để xử lý text như Linux shell.

PowerShell được thiết kế để:

```text
Lấy object → lọc object → chọn property → sắp xếp property → xuất kết quả
```

Công thức lớn nhất:

```powershell
Get-Something | Where-Object ... | Select-Object ... | Sort-Object ...
```

Nghĩa là:

```text
Lấy dữ liệu → lọc → chọn phần cần xem → sắp xếp
```

---

# 1. PowerShell là gì?

PowerShell là một shell + scripting language dùng nhiều cho:

- quản trị Windows
- thao tác file/folder
- process/service
- registry
- network
- automation
- Azure/Microsoft 365
- chạy script `.ps1`

Điểm khác biệt lớn nhất:

```text
PowerShell pipeline truyền object, không chỉ truyền text.
```

Ví dụ:

```powershell
Get-Process
```

Lệnh này không chỉ in chữ ra màn hình.

Nó trả về nhiều **Process object**.

Mỗi object có các property như:

```text
Name
Id
CPU
Path
StartTime
WorkingSet
```

Vì vậy ta có thể viết:

```powershell
Get-Process | Where-Object { $_.CPU -gt 100 }
```

Nghĩa là:

```text
Lấy danh sách process
→ với từng process, kiểm tra property CPU > 100
```

---

# 2. Cmdlet: đơn vị lệnh chuẩn của PowerShell

PowerShell có nhiều lệnh chuẩn gọi là **cmdlet**.

Cmdlet thường có dạng:

```text
Verb-Noun
```

Ví dụ:

```powershell
Get-Process
Get-Service
Get-ChildItem
Set-Location
New-Item
Remove-Item
Start-Service
Stop-Service
```

## 2.1. Vì sao lại là Verb-Noun?

Vì PowerShell muốn lệnh dễ đoán.

Các verb phổ biến:

| Verb | Ý nghĩa | Ví dụ |
|---|---|---|
| Get | lấy/xem | `Get-Process` |
| Set | đặt/sửa | `Set-Location` |
| New | tạo mới | `New-Item` |
| Remove | xóa | `Remove-Item` |
| Start | bắt đầu | `Start-Service` |
| Stop | dừng | `Stop-Process` |
| Restart | khởi động lại | `Restart-Service` |
| Test | kiểm tra đúng/sai | `Test-Path` |
| Invoke | thực thi/gọi chạy | `Invoke-WebRequest` |
| Measure | đo/đếm/tính toán | `Measure-Object` |
| Select | chọn thuộc tính | `Select-Object` |
| Where | lọc | `Where-Object` |
| Sort | sắp xếp | `Sort-Object` |
| Format | định dạng hiển thị | `Format-Table` |

Khi gặp lệnh lạ, hãy tách:

```text
Verb = hành động
Noun = đối tượng bị thao tác
```

Ví dụ:

```powershell
Get-EventLog
```

Đọc là:

```text
Get = lấy
EventLog = nhật ký sự kiện
```

---

# 3. Pipeline trong PowerShell

Pipeline là ký hiệu:

```powershell
|
```

Nó nối output của lệnh trước vào input của lệnh sau.

Ví dụ:

```powershell
Get-Process | Sort-Object CPU
```

Đọc là:

```text
Lấy danh sách process
→ đưa từng process object sang Sort-Object
→ sắp xếp theo property CPU
```

## 3.1. Khác Linux ở đâu?

Linux:

```bash
ps aux | grep chrome
```

Tư duy:

```text
text → text → text
```

PowerShell:

```powershell
Get-Process | Where-Object { $_.ProcessName -like "*chrome*" }
```

Tư duy:

```text
Process object → lọc theo property ProcessName
```

PowerShell không cần cắt cột text nếu object có property thật.

---

# 4. Object và Property là lõi của PowerShell

## 4.1. Object là gì?

Object là một “cục dữ liệu có cấu trúc”.

Ví dụ một file trong PowerShell không chỉ là dòng chữ `app.log`.

Nó là object có property:

```text
Name
FullName
Length
Extension
CreationTime
LastWriteTime
Directory
Exists
```

Ví dụ:

```powershell
Get-ChildItem
```

Trả về các object đại diện cho file/folder.

---

## 4.2. Property là gì?

Property là thông tin nằm trong object.

Ví dụ:

```powershell
Get-ChildItem | Select-Object Name, Length
```

Nghĩa là:

```text
Lấy file/folder
→ chỉ chọn property Name và Length
```

---

## 4.3. Làm sao biết object có property gì?

Dùng:

```powershell
Get-Member
```

Ví dụ:

```powershell
Get-Process | Get-Member
```

Hoặc lấy 1 object mẫu:

```powershell
Get-Process | Select-Object -First 1 | Get-Member
```

Đây là lệnh cực kỳ quan trọng.

Khi không biết lọc/sort/chọn theo cái gì, hãy hỏi object trước:

```powershell
... | Get-Member
```

Tư duy:

```text
Muốn xử lý object thì phải biết object có property nào.
```

---

# 5. `$_` là gì?

Trong PowerShell pipeline, `$_` là:

```text
object hiện tại đang được xử lý
```

Ví dụ:

```powershell
Get-Process | Where-Object { $_.CPU -gt 100 }
```

Nghĩa là:

```text
Với từng process object:
    nếu process.CPU > 100 thì giữ lại
```

Tưởng tượng giống Python:

```python
for process in processes:
    if process.CPU > 100:
        print(process)
```

Trong PowerShell:

```powershell
$_
```

chính là `process` hiện tại.

---

# 6. Script block `{ ... }`

Trong PowerShell, `{ ... }` thường là **script block**.

Nó giống một đoạn code nhỏ được đưa cho lệnh khác dùng.

Ví dụ:

```powershell
Where-Object { $_.Length -gt 1MB }
```

Đọc là:

```text
Where-Object nhận một đoạn điều kiện
Điều kiện đó là: object hiện tại có Length > 1MB
```

Ví dụ khác:

```powershell
ForEach-Object { $_.Name }
```

Đọc là:

```text
Với từng object, lấy property Name
```

---

# 7. Nhóm lệnh xử lý object phổ biến nhất

Nếu chỉ nhớ một nhóm, hãy nhớ nhóm này:

```powershell
Where-Object
Select-Object
Sort-Object
Measure-Object
ForEach-Object
Group-Object
Format-Table
Format-List
```

---

## 7.1. `Where-Object`: lọc object

Công dụng:

```text
Giữ lại object thỏa điều kiện.
```

Ví dụ:

```powershell
Get-Process | Where-Object { $_.CPU -gt 100 }
```

Đọc:

```text
Lấy process có CPU > 100
```

Ví dụ file:

```powershell
Get-ChildItem | Where-Object { $_.Extension -eq ".log" }
```

Đọc:

```text
Lấy file có extension là .log
```

Viết ngắn:

```powershell
Get-ChildItem | Where-Object Extension -eq ".log"
```

---

## 7.2. `Select-Object`: chọn property

Công dụng:

```text
Chỉ lấy một vài property cần xem.
```

Ví dụ:

```powershell
Get-Process | Select-Object Name, Id, CPU
```

Đọc:

```text
Lấy process, chỉ hiển thị Name, Id, CPU
```

Lấy vài dòng đầu:

```powershell
Get-Process | Select-Object -First 5
```

Lấy vài dòng cuối:

```powershell
Get-Process | Select-Object -Last 5
```

Bỏ qua vài dòng đầu:

```powershell
Get-Process | Select-Object -Skip 10
```

---

## 7.3. `Sort-Object`: sắp xếp object

Công dụng:

```text
Sắp xếp theo property.
```

Ví dụ:

```powershell
Get-Process | Sort-Object CPU
```

Sắp xếp giảm dần:

```powershell
Get-Process | Sort-Object CPU -Descending
```

Sắp xếp file theo thời gian sửa:

```powershell
Get-ChildItem | Sort-Object LastWriteTime -Descending
```

Đọc:

```text
Lấy file/folder
→ sắp xếp theo LastWriteTime mới nhất trước
```

---

## 7.4. `Measure-Object`: đếm/tính tổng/trung bình/min/max

Công dụng:

```text
Đo dữ liệu.
```

Đếm số object:

```powershell
Get-ChildItem | Measure-Object
```

Tính tổng dung lượng file:

```powershell
Get-ChildItem -File | Measure-Object -Property Length -Sum
```

Đọc:

```text
Lấy danh sách file
→ lấy property Length của mỗi file
→ tính tổng
```

Kết quả thường có property:

```text
Count
Average
Sum
Maximum
Minimum
```

---

## 7.5. `ForEach-Object`: xử lý từng object

Công dụng:

```text
Lặp qua từng object trong pipeline.
```

Ví dụ:

```powershell
Get-ChildItem | ForEach-Object { $_.Name }
```

Đọc:

```text
Với từng file/folder, lấy Name
```

Ví dụ đổi tên file:

```powershell
Get-ChildItem *.txt | ForEach-Object {
    Rename-Item $_.FullName ($_.BaseName + ".bak")
}
```

Tư duy:

```text
ForEach-Object = for each item in pipeline
```

---

## 7.6. `Group-Object`: nhóm object

Công dụng:

```text
Nhóm object theo property.
```

Ví dụ nhóm file theo extension:

```powershell
Get-ChildItem -File | Group-Object Extension
```

Đọc:

```text
Lấy file
→ nhóm theo Extension
```

Ví dụ nhóm process theo company:

```powershell
Get-Process | Group-Object Company
```

---

## 7.7. `Format-Table`: hiển thị dạng bảng

Công dụng:

```text
Chỉ dùng để định dạng hiển thị.
```

Ví dụ:

```powershell
Get-Process | Format-Table Name, Id, CPU
```

Quan trọng:

```text
Format-Table nên để cuối pipeline.
```

Không nên:

```powershell
Get-Process | Format-Table Name, Id | Where-Object { $_.Id -gt 1000 }
```

Vì sau `Format-Table`, dữ liệu đã bị biến thành object phục vụ format, không còn là process object gốc nữa.

Đúng hơn:

```powershell
Get-Process |
    Where-Object { $_.Id -gt 1000 } |
    Format-Table Name, Id
```

Quy tắc nhớ:

```text
Xử lý dữ liệu trước, format hiển thị sau cùng.
```

---

## 7.8. `Format-List`: hiển thị chi tiết dạng list

Ví dụ:

```powershell
Get-Process -Id 1234 | Format-List *
```

Dùng khi muốn xem nhiều property của một object.

---

# 8. Nhóm toán tử so sánh thường gặp

PowerShell không dùng `==`, `>`, `<` theo kiểu phổ biến trong nhiều ngôn ngữ khi so sánh trong command.

Nó hay dùng:

| Toán tử | Ý nghĩa |
|---|---|
| `-eq` | equal, bằng |
| `-ne` | not equal, khác |
| `-gt` | greater than, lớn hơn |
| `-ge` | greater or equal, lớn hơn hoặc bằng |
| `-lt` | less than, nhỏ hơn |
| `-le` | less or equal, nhỏ hơn hoặc bằng |
| `-like` | so khớp wildcard |
| `-notlike` | không khớp wildcard |
| `-match` | so khớp regex |
| `-notmatch` | không khớp regex |
| `-contains` | collection chứa giá trị |
| `-notcontains` | collection không chứa giá trị |
| `-in` | giá trị nằm trong collection |
| `-notin` | giá trị không nằm trong collection |

Ví dụ:

```powershell
Get-Process | Where-Object { $_.CPU -gt 100 }
```

```text
CPU lớn hơn 100
```

```powershell
Get-Service | Where-Object { $_.Status -eq "Running" }
```

```text
Status bằng Running
```

```powershell
Get-ChildItem | Where-Object { $_.Name -like "*.log" }
```

```text
Name khớp mẫu *.log
```

---

# 9. Wildcard và Regex

## 9.1. Wildcard với `-like`

Wildcard đơn giản:

| Ký hiệu | Ý nghĩa |
|---|---|
| `*` | bất kỳ chuỗi nào |
| `?` | một ký tự bất kỳ |

Ví dụ:

```powershell
"app.log" -like "*.log"
```

Kết quả:

```text
True
```

Ví dụ:

```powershell
Get-ChildItem | Where-Object { $_.Name -like "app*" }
```

Đọc:

```text
Lấy file/folder có tên bắt đầu bằng app
```

---

## 9.2. Regex với `-match`

Regex mạnh hơn wildcard.

Ví dụ:

```powershell
"error-500" -match "\d+"
```

Nghĩa là:

```text
Chuỗi có chứa một hoặc nhiều chữ số không?
```

Kết quả:

```text
True
```

Dùng khi pattern phức tạp.

---

# 10. Parameter: tham số của lệnh

PowerShell parameter thường có dạng:

```powershell
-Name value
```

Ví dụ:

```powershell
Get-ChildItem -Path . -Recurse -File
```

Đọc:

```text
Get-ChildItem
-Path .       = bắt đầu từ thư mục hiện tại
-Recurse      = đi sâu vào thư mục con
-File         = chỉ lấy file
```

## 10.1. Parameter dạng switch

Một số parameter không cần value.

Ví dụ:

```powershell
-Recurse
-File
-Directory
-Force
-WhatIf
-Confirm
```

Chúng giống công tắc bật/tắt.

Ví dụ:

```powershell
Get-ChildItem -Force
```

Đọc:

```text
Lấy cả item ẩn/system nếu có
```

---

## 10.2. Parameter có thể viết tắt không?

Có, miễn là không gây mơ hồ.

Ví dụ:

```powershell
Get-ChildItem -Recurse
```

Có thể viết:

```powershell
Get-ChildItem -Rec
```

Nhưng khi học, nên viết đầy đủ để dễ đọc.

---

## 10.3. Positional parameter

Một số parameter có thể bỏ tên.

Ví dụ:

```powershell
Get-ChildItem C:\Temp
```

Tương đương:

```powershell
Get-ChildItem -Path C:\Temp
```

Nhưng để đọc hiểu tốt hơn, nên tưởng tượng nó là:

```powershell
Get-ChildItem -Path C:\Temp
```

---

# 11. Alias: tên tắt dễ gây hiểu nhầm

PowerShell có nhiều alias để người quen Linux/CMD dễ dùng.

Ví dụ:

| Alias | Lệnh thật |
|---|---|
| `ls` | `Get-ChildItem` |
| `dir` | `Get-ChildItem` |
| `cd` | `Set-Location` |
| `pwd` | `Get-Location` |
| `cat` | `Get-Content` |
| `echo` | `Write-Output` |
| `rm` | `Remove-Item` |
| `cp` | `Copy-Item` |
| `mv` | `Move-Item` |
| `sort` | `Sort-Object` |
| `where` | `Where-Object` |
| `%` | `ForEach-Object` |
| `?` | `Where-Object` |

Ví dụ:

```powershell
ls
```

Thực chất là:

```powershell
Get-ChildItem
```

Ví dụ:

```powershell
Get-Process | ? CPU -gt 100
```

Thực chất là:

```powershell
Get-Process | Where-Object CPU -gt 100
```

Khuyên dùng khi học:

```text
Tránh alias trong giai đoạn đầu.
Hãy dùng tên đầy đủ để hiểu bản chất.
```

---

# 12. Biến trong PowerShell

Biến bắt đầu bằng `$`.

Ví dụ:

```powershell
$name = "Hoang"
$count = 10
```

In biến:

```powershell
$name
```

Dùng biến trong command:

```powershell
$path = "C:\Temp"
Get-ChildItem -Path $path
```

---

## 12.1. Biến đặc biệt thường gặp

| Biến | Ý nghĩa |
|---|---|
| `$_` | object hiện tại trong pipeline |
| `$PSItem` | giống `$_` |
| `$null` | giá trị rỗng/null |
| `$true` | true |
| `$false` | false |
| `$HOME` | thư mục home của user |
| `$PWD` | thư mục hiện tại |
| `$LASTEXITCODE` | exit code của native command gần nhất |
| `$?` | lệnh gần nhất thành công hay không |

Ví dụ:

```powershell
Get-Process | Where-Object { $_.CPU -gt 100 }
```

`$_` là process hiện tại.

---

# 13. String: nháy đơn và nháy kép

## 13.1. Nháy đơn `'...'`

Nháy đơn giữ nguyên nội dung.

```powershell
$name = "Hoang"
'Hello $name'
```

Kết quả:

```text
Hello $name
```

## 13.2. Nháy kép `"..."`

Nháy kép cho phép nhúng biến.

```powershell
$name = "Hoang"
"Hello $name"
```

Kết quả:

```text
Hello Hoang
```

Quy tắc nhớ:

```text
'...' = literal, giữ nguyên
"..." = interpolate, thay biến vào
```

---

# 14. Array và Hashtable

## 14.1. Array

Array là danh sách.

```powershell
$names = @("An", "Binh", "Cuong")
```

Truy cập phần tử:

```powershell
$names[0]
```

Lặp:

```powershell
$names | ForEach-Object { "Hello $_" }
```

---

## 14.2. Hashtable

Hashtable là cặp key-value.

```powershell
$user = @{
    Name = "Hoang"
    Age = 30
}
```

Truy cập:

```powershell
$user["Name"]
```

Hoặc:

```powershell
$user.Name
```

Hashtable hay xuất hiện trong config, tham số phức tạp, splatting.

---

# 15. Splatting: truyền nhiều parameter gọn hơn

Thay vì viết:

```powershell
Get-ChildItem -Path "C:\Temp" -Recurse -File
```

Có thể viết:

```powershell
$params = @{
    Path = "C:\Temp"
    Recurse = $true
    File = $true
}

Get-ChildItem @params
```

`@params` gọi là splatting.

Đọc là:

```text
Lấy các key-value trong hashtable làm parameter cho command.
```

---

# 16. Provider: PowerShell không chỉ nhìn file system

PowerShell có khái niệm **provider**.

Nghĩa là nó cho phép truy cập nhiều loại dữ liệu như đang đi trong thư mục.

Ví dụ:

```powershell
C:\
Env:
Alias:
Function:
Variable:
Cert:
HKCU:
HKLM:
```

Ví dụ xem biến môi trường:

```powershell
Get-ChildItem Env:
```

Xem alias:

```powershell
Get-ChildItem Alias:
```

Vào registry:

```powershell
Set-Location HKCU:
```

Ý tưởng:

```text
PowerShell biến nhiều nguồn dữ liệu thành dạng giống filesystem.
```

---

# 17. Item: khái niệm chung cho file/folder/registry/...

Nhiều lệnh có chữ `Item`.

Ví dụ:

```powershell
Get-Item
Get-ChildItem
New-Item
Remove-Item
Copy-Item
Move-Item
Rename-Item
Set-Item
```

`Item` không chỉ là file.

Tùy provider, item có thể là:

```text
file
folder
registry key
environment variable
alias
function
certificate
```

Ví dụ file:

```powershell
Get-Item C:\Temp\app.log
```

Ví dụ biến môi trường:

```powershell
Get-Item Env:Path
```

---

# 18. Các lệnh file/folder common

## 18.1. Xem vị trí hiện tại

```powershell
Get-Location
```

Alias:

```powershell
pwd
```

---

## 18.2. Chuyển thư mục

```powershell
Set-Location C:\Temp
```

Alias:

```powershell
cd C:\Temp
```

---

## 18.3. Liệt kê file/folder

```powershell
Get-ChildItem
```

Alias:

```powershell
ls
dir
```

Ví dụ:

```powershell
Get-ChildItem -Path C:\Temp
```

Đi sâu thư mục con:

```powershell
Get-ChildItem -Path C:\Temp -Recurse
```

Chỉ lấy file:

```powershell
Get-ChildItem -File
```

Chỉ lấy folder:

```powershell
Get-ChildItem -Directory
```

---

## 18.4. Tạo file/folder

Tạo folder:

```powershell
New-Item -ItemType Directory -Path C:\Temp\logs
```

Tạo file:

```powershell
New-Item -ItemType File -Path C:\Temp\app.log
```

---

## 18.5. Xóa file/folder

```powershell
Remove-Item C:\Temp\app.log
```

Xóa folder có nội dung bên trong:

```powershell
Remove-Item C:\Temp\logs -Recurse
```

Nên kiểm tra trước bằng `-WhatIf`:

```powershell
Remove-Item C:\Temp\logs -Recurse -WhatIf
```

Đọc:

```text
Nếu chạy thật thì sẽ xóa gì?
```

---

## 18.6. Copy/move/rename

Copy:

```powershell
Copy-Item source.txt dest.txt
```

Move:

```powershell
Move-Item source.txt C:\Temp\
```

Rename:

```powershell
Rename-Item old.txt new.txt
```

---

# 19. Đọc/ghi nội dung file

## 19.1. Đọc file

```powershell
Get-Content app.log
```

Alias:

```powershell
cat app.log
```

Đọc vài dòng cuối:

```powershell
Get-Content app.log -Tail 20
```

Theo dõi file log realtime:

```powershell
Get-Content app.log -Wait
```

Tương tự Linux:

```bash
tail -f app.log
```

PowerShell:

```powershell
Get-Content app.log -Tail 20 -Wait
```

---

## 19.2. Ghi file

Ghi đè:

```powershell
Set-Content output.txt "Hello"
```

Ghi thêm:

```powershell
Add-Content output.txt "New line"
```

Redirect ghi file:

```powershell
Get-Process > processes.txt
```

Ghi dạng text có kiểm soát hơn:

```powershell
Get-Process | Out-File processes.txt
```

---

## 19.3. Xuất CSV

Vì PowerShell có object, xuất CSV rất tiện:

```powershell
Get-Process | Select-Object Name, Id, CPU | Export-Csv processes.csv -NoTypeInformation
```

Đọc:

```text
Lấy process
→ chọn Name, Id, CPU
→ xuất ra CSV
```

---

## 19.4. Nhập CSV

```powershell
Import-Csv users.csv
```

Mỗi dòng CSV trở thành một object.

Ví dụ:

```powershell
Import-Csv users.csv | Where-Object { $_.Department -eq "IT" }
```

---

# 20. Process và Service

## 20.1. Process

Xem process:

```powershell
Get-Process
```

Tìm process theo tên:

```powershell
Get-Process chrome
```

Lọc process CPU cao:

```powershell
Get-Process | Where-Object { $_.CPU -gt 100 }
```

Dừng process:

```powershell
Stop-Process -Name notepad
```

Dừng theo Id:

```powershell
Stop-Process -Id 1234
```

Nên kiểm tra:

```powershell
Stop-Process -Id 1234 -WhatIf
```

---

## 20.2. Service

Xem service:

```powershell
Get-Service
```

Tìm service đang chạy:

```powershell
Get-Service | Where-Object { $_.Status -eq "Running" }
```

Start service:

```powershell
Start-Service -Name Spooler
```

Stop service:

```powershell
Stop-Service -Name Spooler
```

Restart service:

```powershell
Restart-Service -Name Spooler
```

---

# 21. Error trong PowerShell

PowerShell có 2 loại lỗi quan trọng:

```text
Terminating error
Non-terminating error
```

## 21.1. Non-terminating error

Một số lỗi hiện ra nhưng script vẫn chạy tiếp.

Ví dụ:

```powershell
Get-ChildItem C:\NotExist
```

Có thể báo lỗi nhưng pipeline/script chưa chắc đã dừng hoàn toàn.

## 21.2. Terminating error

Lỗi nghiêm trọng làm dừng execution.

## 21.3. `-ErrorAction`

Có thể điều khiển cách xử lý lỗi:

```powershell
Get-ChildItem C:\NotExist -ErrorAction Stop
```

Các giá trị hay gặp:

| Giá trị | Ý nghĩa |
|---|---|
| `Continue` | báo lỗi rồi tiếp tục |
| `SilentlyContinue` | bỏ qua lỗi, không in |
| `Stop` | biến lỗi thành terminating error |
| `Inquire` | hỏi người dùng |
| `Ignore` | bỏ qua |

Ví dụ try/catch:

```powershell
try {
    Get-ChildItem C:\NotExist -ErrorAction Stop
}
catch {
    Write-Host "Có lỗi xảy ra: $($_.Exception.Message)"
}
```

---

# 22. `-WhatIf` và `-Confirm`: bảo vệ khi chạy lệnh nguy hiểm

Nhiều lệnh thay đổi hệ thống hỗ trợ:

```powershell
-WhatIf
-Confirm
```

Ví dụ:

```powershell
Remove-Item C:\Temp\*.log -WhatIf
```

Đọc:

```text
Không xóa thật, chỉ cho biết nếu chạy thật thì sẽ xóa gì.
```

Ví dụ:

```powershell
Remove-Item C:\Temp\*.log -Confirm
```

Đọc:

```text
Hỏi xác nhận trước khi xóa.
```

Quy tắc:

```text
Lệnh xóa/sửa hàng loạt → thử -WhatIf trước.
```

---

# 23. Execution Policy

Khi chạy script `.ps1`, bạn có thể gặp lỗi kiểu:

```text
cannot be loaded because running scripts is disabled on this system
```

Đây là do Execution Policy.

Xem policy:

```powershell
Get-ExecutionPolicy
```

Xem tất cả scope:

```powershell
Get-ExecutionPolicy -List
```

Cho phép chạy script trong session hiện tại:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Cho user hiện tại:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Ý nghĩa common:

| Policy | Ý nghĩa |
|---|---|
| `Restricted` | không cho chạy script |
| `RemoteSigned` | script local chạy được, script tải từ internet cần signed |
| `Bypass` | bỏ qua kiểm tra |
| `Unrestricted` | ít hạn chế hơn, nhưng không nên dùng bừa |

Gợi ý an toàn khi học:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Vì chỉ áp dụng cho cửa sổ PowerShell hiện tại.

---

# 24. Help system: cách tự học lệnh lạ

Đây là phần rất quan trọng để không học vẹt.

## 24.1. Xem help

```powershell
Get-Help Get-ChildItem
```

Xem ví dụ:

```powershell
Get-Help Get-ChildItem -Examples
```

Xem đầy đủ:

```powershell
Get-Help Get-ChildItem -Full
```

Mở online:

```powershell
Get-Help Get-ChildItem -Online
```

---

## 24.2. Tìm lệnh

```powershell
Get-Command *Service*
```

Tìm lệnh có verb cụ thể:

```powershell
Get-Command -Verb Get
```

Tìm lệnh có noun cụ thể:

```powershell
Get-Command -Noun Service
```

---

## 24.3. Xem property/method của output

```powershell
Get-Process | Get-Member
```

Đây là cặp lệnh phải nhớ:

```powershell
Get-Help
Get-Member
```

Một cái giúp hiểu command.  
Một cái giúp hiểu output object.

---

# 25. Cách đọc một lệnh PowerShell bất kỳ

Khi gặp lệnh:

```powershell
Get-ChildItem -Path C:\Logs -Recurse -File |
    Where-Object { $_.Length -gt 10MB } |
    Sort-Object Length -Descending |
    Select-Object Name, Length, FullName
```

Đừng đọc từ ký tự lẻ.

Hãy chia theo pipeline:

```text
1. Get-ChildItem -Path C:\Logs -Recurse -File
2. Where-Object { $_.Length -gt 10MB }
3. Sort-Object Length -Descending
4. Select-Object Name, Length, FullName
```

Sau đó đọc:

```text
1. Lấy tất cả file trong C:\Logs và thư mục con
2. Chỉ giữ file có Length > 10MB
3. Sắp xếp theo Length giảm dần
4. Chỉ hiển thị Name, Length, FullName
```

Công thức phân tích:

```text
Bước 1: Lệnh đầu tiên lấy object gì?
Bước 2: Pipeline sau lọc/chọn/sort/group/measure gì?
Bước 3: Các property được dùng là gì?
Bước 4: Cuối cùng là hiển thị, xuất file, hay thao tác thay đổi hệ thống?
```

---

# 26. Cách phân biệt “xử lý dữ liệu” và “hiển thị dữ liệu”

PowerShell có một bẫy lớn:

```powershell
Format-Table
Format-List
```

Hai lệnh này dùng cho hiển thị.

Không nên đưa chúng vào giữa pipeline xử lý dữ liệu.

Sai tư duy:

```powershell
Get-Process |
    Format-Table Name, Id |
    Export-Csv processes.csv
```

Vì lúc này CSV không còn chứa process object đẹp nữa.

Đúng:

```powershell
Get-Process |
    Select-Object Name, Id |
    Export-Csv processes.csv -NoTypeInformation
```

Quy tắc nhớ:

```text
Muốn xuất dữ liệu → dùng Select-Object / Export-Csv
Muốn nhìn đẹp trên màn hình → dùng Format-Table / Format-List
```

---

# 27. Output của PowerShell nhìn là table nhưng bên trong vẫn là object

Ví dụ:

```powershell
Get-Process
```

Màn hình có thể hiển thị như table:

```text
Handles  NPM(K)  PM(K)  WS(K) CPU(s) Id ProcessName
```

Nhưng đây chỉ là cách PowerShell format để người đọc dễ nhìn.

Bên trong pipeline vẫn là object.

Vì thế:

```powershell
Get-Process | Select-Object Name, Id
```

vẫn lấy được property thật.

---

# 28. Native command trong PowerShell

Không phải mọi thứ trong PowerShell đều trả object đẹp.

Ví dụ:

```powershell
git status
ping google.com
npm install
python --version
```

Đây là native command bên ngoài PowerShell.

Chúng thường trả text.

Nên cần phân biệt:

```text
PowerShell cmdlet → thường trả object
Native command → thường trả text
```

Ví dụ:

```powershell
git status | Select-String "modified"
```

Ở đây dùng `Select-String` để tìm trong text là hợp lý.

---

# 29. `Select-String`: grep của PowerShell

Dùng để tìm text trong file/string.

Ví dụ:

```powershell
Select-String -Path *.log -Pattern "ERROR"
```

Đọc:

```text
Tìm chuỗi ERROR trong các file .log
```

Tìm đệ quy:

```powershell
Get-ChildItem -Recurse -File |
    Select-String -Pattern "staging"
```

Lưu ý:

```text
Select-String xử lý text.
Where-Object xử lý object/property.
```

Ví dụ object:

```powershell
Get-ChildItem | Where-Object { $_.Extension -eq ".log" }
```

Ví dụ text:

```powershell
Get-Content app.log | Select-String "ERROR"
```

---

# 30. Redirect và pipeline

## 30.1. Pipeline `|`

Truyền output sang command khác:

```powershell
Get-Process | Sort-Object CPU
```

## 30.2. Redirect `>`

Ghi output ra file:

```powershell
Get-Process > processes.txt
```

Ghi thêm:

```powershell
Get-Process >> processes.txt
```

## 30.3. Out-File

```powershell
Get-Process | Out-File processes.txt
```

## 30.4. Tee-Object

Vừa hiển thị vừa ghi file:

```powershell
Get-Process | Tee-Object processes.txt
```

---

# 31. Common command patterns

## 31.1. Lấy top process ăn CPU

```powershell
Get-Process |
    Sort-Object CPU -Descending |
    Select-Object -First 10 Name, Id, CPU
```

Đọc:

```text
Lấy process
→ sort CPU giảm dần
→ lấy 10 dòng đầu
→ hiển thị Name, Id, CPU
```

---

## 31.2. Tìm file lớn hơn 100MB

```powershell
Get-ChildItem -Path . -Recurse -File |
    Where-Object { $_.Length -gt 100MB } |
    Select-Object Name, Length, FullName
```

---

## 31.3. Tính tổng dung lượng file trong folder

```powershell
Get-ChildItem -Path . -Recurse -File |
    Measure-Object -Property Length -Sum
```

---

## 31.4. Tìm text trong file

```powershell
Select-String -Path .\*.log -Pattern "ERROR"
```

---

## 31.5. Tìm text đệ quy

```powershell
Get-ChildItem -Path . -Recurse -File |
    Select-String -Pattern "staging"
```

---

## 31.6. Lấy service đang stopped

```powershell
Get-Service |
    Where-Object { $_.Status -eq "Stopped" }
```

---

## 31.7. Export danh sách process ra CSV

```powershell
Get-Process |
    Select-Object Name, Id, CPU |
    Export-Csv processes.csv -NoTypeInformation
```

---

# 32. Mapping tư duy Linux sang PowerShell

| Mục đích | Linux | PowerShell |
|---|---|---|
| List file | `ls` | `Get-ChildItem` |
| Current dir | `pwd` | `Get-Location` |
| Change dir | `cd` | `Set-Location` |
| Read file | `cat file` | `Get-Content file` |
| Search text | `grep pattern file` | `Select-String -Pattern pattern -Path file` |
| Count lines | `wc -l` | `(Get-Content file).Count` |
| Find files | `find . -name "*.log"` | `Get-ChildItem -Recurse -Filter "*.log"` |
| Sort | `sort` | `Sort-Object` |
| Unique | `uniq` | `Select-Object -Unique` |
| Process list | `ps` | `Get-Process` |
| Kill process | `kill` | `Stop-Process` |
| Disk usage | `du` | thường dùng `Get-ChildItem` + `Measure-Object` |
| Output file | `>` | `>` hoặc `Out-File` |
| CSV | awk/sed/cut | `Export-Csv`, `Import-Csv` |

---

# 33. Một vài lệnh bạn nên nhớ theo “vai trò”

## 33.1. Khám phá hệ thống

```powershell
Get-Command
Get-Help
Get-Member
```

## 33.2. File/folder

```powershell
Get-Location
Set-Location
Get-ChildItem
Get-Item
New-Item
Remove-Item
Copy-Item
Move-Item
Rename-Item
```

## 33.3. Nội dung file

```powershell
Get-Content
Set-Content
Add-Content
Select-String
Out-File
```

## 33.4. Object pipeline

```powershell
Where-Object
Select-Object
Sort-Object
Measure-Object
ForEach-Object
Group-Object
```

## 33.5. Hiển thị/export

```powershell
Format-Table
Format-List
Export-Csv
Import-Csv
ConvertTo-Json
ConvertFrom-Json
```

## 33.6. Process/service

```powershell
Get-Process
Stop-Process
Get-Service
Start-Service
Stop-Service
Restart-Service
```

---

# 34. JSON trong PowerShell

PowerShell làm việc với JSON khá tốt.

Convert object sang JSON:

```powershell
Get-Process |
    Select-Object -First 3 Name, Id |
    ConvertTo-Json
```

Đọc JSON từ file:

```powershell
$data = Get-Content config.json | ConvertFrom-Json
```

Truy cập property:

```powershell
$data.database.host
```

Điểm mạnh:

```text
JSON text → ConvertFrom-Json → object
object → ConvertTo-Json → JSON text
```

---

# 35. Dấu xuống dòng cho pipeline dài

Có thể viết pipeline nhiều dòng để dễ đọc:

```powershell
Get-ChildItem -Path . -Recurse -File |
    Where-Object { $_.Length -gt 10MB } |
    Sort-Object Length -Descending |
    Select-Object Name, Length, FullName
```

Nếu cần xuống dòng không ở sau pipe, có thể dùng backtick:

```powershell
Get-ChildItem `
    -Path . `
    -Recurse `
    -File
```

Nhưng nên hạn chế backtick nếu có cách viết rõ hơn.

---

# 36. Comment trong PowerShell

Comment một dòng:

```powershell
# Đây là comment
```

Comment nhiều dòng:

```powershell
<#
Đây là comment nhiều dòng
#>
```

---

# 37. Function trong PowerShell

Ví dụ đơn giản:

```powershell
function Say-Hello {
    param(
        [string]$Name
    )

    "Hello $Name"
}
```

Gọi:

```powershell
Say-Hello -Name "Hoang"
```

Cấu trúc:

```text
function Tên-Hàm {
    param(...)
    code
}
```

PowerShell function cũng nên đặt kiểu Verb-Noun.

---

# 38. Điều kiện if

```powershell
$age = 20

if ($age -ge 18) {
    "Adult"
}
else {
    "Child"
}
```

Lưu ý:

```text
So sánh dùng -ge, -eq, -lt...
```

---

# 39. Vòng lặp

## 39.1. foreach statement

```powershell
$files = Get-ChildItem

foreach ($file in $files) {
    $file.Name
}
```

## 39.2. ForEach-Object trong pipeline

```powershell
Get-ChildItem | ForEach-Object {
    $_.Name
}
```

Khác biệt:

```text
foreach statement: thường dùng với biến/list đã có
ForEach-Object: dùng trong pipeline
```

---

# 40. Module

PowerShell mở rộng bằng module.

Xem module đang có:

```powershell
Get-Module -ListAvailable
```

Import module:

```powershell
Import-Module ModuleName
```

Cài module:

```powershell
Install-Module ModuleName
```

Ví dụ nhiều công cụ cloud/admin cung cấp module riêng.

---

# 41. Profile PowerShell

Profile là file script chạy mỗi khi mở PowerShell.

Xem đường dẫn profile:

```powershell
$PROFILE
```

Kiểm tra có tồn tại không:

```powershell
Test-Path $PROFILE
```

Tạo profile nếu chưa có:

```powershell
New-Item -ItemType File -Path $PROFILE -Force
```

Mở bằng Notepad:

```powershell
notepad $PROFILE
```

Dùng để đặt alias/function/config cá nhân.

---

# 42. Cách học PowerShell không quên nhanh

## 42.1. Đừng nhớ lệnh, hãy nhớ pattern

Pattern 1:

```powershell
Get-X | Where-Object ...
```

Nghĩa:

```text
Lấy X rồi lọc
```

Pattern 2:

```powershell
Get-X | Select-Object A, B, C
```

Nghĩa:

```text
Lấy X rồi chỉ chọn vài property
```

Pattern 3:

```powershell
Get-X | Sort-Object Property -Descending
```

Nghĩa:

```text
Lấy X rồi sort theo property
```

Pattern 4:

```powershell
Get-X | Measure-Object -Property Property -Sum
```

Nghĩa:

```text
Lấy X rồi tính tổng property
```

---

## 42.2. Gặp lệnh lạ thì phân tích theo 5 câu hỏi

```text
1. Lệnh đầu tiên lấy object gì?
2. Object đó có property nào?
3. Pipeline đang lọc/chọn/sort/group/measure?
4. Có lệnh nào thay đổi hệ thống không? Remove/Set/New/Stop/Start?
5. Kết quả cuối là hiển thị, ghi file, export CSV/JSON, hay thay đổi thật?
```

---

## 42.3. Luôn dùng Get-Member khi không hiểu property

Ví dụ:

```powershell
Get-ChildItem | Get-Member
```

Sau đó bạn sẽ biết có:

```text
Name
FullName
Length
Extension
LastWriteTime
```

Rồi mới hiểu vì sao lệnh này chạy được:

```powershell
Get-ChildItem | Where-Object { $_.Length -gt 1MB }
```

---

# 43. Mini dictionary: đọc nhanh ký hiệu PowerShell

| Ký hiệu | Cách hiểu |
|---|---|
| `|` | truyền object sang lệnh sau |
| `$_` | object hiện tại |
| `$var` | biến |
| `{ ... }` | script block |
| `@(...)` | array |
| `@{...}` | hashtable |
| `@params` | splatting parameter |
| `-eq` | bằng |
| `-gt` | lớn hơn |
| `-lt` | nhỏ hơn |
| `-like` | so khớp wildcard |
| `-match` | so khớp regex |
| `>` | ghi đè output ra file |
| `>>` | ghi thêm output ra file |
| `#` | comment |
| `;` | ngăn cách nhiều statement trên một dòng |
| `\` | ký tự path phổ biến trên Windows |
| `.` | thư mục hiện tại |
| `..` | thư mục cha |

---

# 44. Bài tập đọc hiểu nhanh

## Bài 1

```powershell
Get-ChildItem -Recurse -File |
    Where-Object { $_.Extension -eq ".log" } |
    Select-Object Name, FullName
```

Đáp án:

```text
Lấy tất cả file trong thư mục hiện tại và thư mục con
→ chỉ giữ file có extension .log
→ hiển thị Name và FullName
```

---

## Bài 2

```powershell
Get-Process |
    Sort-Object WorkingSet -Descending |
    Select-Object -First 5 Name, Id, WorkingSet
```

Đáp án:

```text
Lấy process
→ sort theo WorkingSet giảm dần
→ lấy 5 process đầu
→ hiển thị Name, Id, WorkingSet
```

---

## Bài 3

```powershell
Get-Service |
    Where-Object { $_.Status -eq "Stopped" } |
    Measure-Object
```

Đáp án:

```text
Lấy service
→ lọc service đang stopped
→ đếm số lượng
```

---

## Bài 4

```powershell
Get-Content .\app.log |
    Select-String "ERROR"
```

Đáp án:

```text
Đọc nội dung app.log
→ tìm các dòng chứa ERROR
```

---

## Bài 5

```powershell
Get-ChildItem -Path . -Recurse -File |
    Measure-Object -Property Length -Sum
```

Đáp án:

```text
Lấy tất cả file trong thư mục hiện tại và thư mục con
→ lấy property Length
→ tính tổng dung lượng
```

---

# 45. Tổng kết cuối

Muốn đọc hiểu PowerShell, hãy luôn nhớ:

```text
PowerShell không chỉ chạy lệnh.
PowerShell cho object đi qua pipeline.
```

Cách đọc đúng:

```text
Get = lấy object
Where = lọc object
Select = chọn property
Sort = sắp xếp theo property
Measure = đo/tính property
Format = chỉ để hiển thị
Export = xuất dữ liệu
```

Một câu cực ngắn:

```text
PowerShell = object pipeline + Verb-Noun + property-based thinking.
```

Nếu gặp lệnh lạ, đừng hoảng. Hãy hỏi:

```text
Lệnh này trả object gì?
Object đó có property nào?
Pipeline sau đang làm gì với property đó?
```

Sau đó dùng:

```powershell
Get-Help <Command> -Examples
<Command> | Get-Member
```

Đây là cách học để nhớ lâu hơn, vì bạn hiểu **vì sao lệnh được viết như vậy**.
