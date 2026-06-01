# 🧩 **Bash for Java Developers – Complete Guide**

> **Mục tiêu:** Giúp lập trình viên Java học Bash nhanh nhất qua mapping trực tiếp, từ cơ bản đến nâng cao.

---

## 📋 **Table of Contents**

1. [Biến (Variables)](#1️⃣-biến-variables)
2.  [Toán tử (Operators)](#2️⃣-toán-tử-operators)
3. [Điều kiện (Conditionals)](#3️⃣-điều-kiện-conditionals)
4. [Vòng lặp (Loops)](#4️⃣-vòng-lặp-loops)
5. [Function (Hàm)](#5️⃣-function-hàm)
6. [Mảng (Arrays)](#6️⃣-mảng-arrays)
7. [Map / Associative Array](#7️⃣-map--associative-array-bash-4)
8. [Kiểm tra file / thư mục](#8️⃣-kiểm-tra-file--thư-mục)
9. [Command Substitution](#9️⃣-command-substitution)
10. [Exit Code & Error Handling](#🔟-exit-code--error-handling)
11. [String Manipulation](#1️⃣1️⃣-string-manipulation)
12. [Input/Output & Redirection](#1️⃣2️⃣-inputoutput--redirection)
13. [Pipes & Chaining Commands](#1️⃣3️⃣-pipes--chaining-commands)
14. [Debugging & Best Practices](#1️⃣4️⃣-debugging--best-practices)
15. [Ví dụ thực tế](#1️⃣5️⃣-ví-dụ-thực-tế)

---

## 1️⃣ **Biến (Variables)**

| Bash | Java | Giải thích |
|------|------|------------|
| `VAR=value` | `String var = "value";` | Gán biến (không có space quanh `=`) |
| `${VAR}` hoặc `$VAR` | `var` | Tham chiếu biến |
| `readonly VAR=value` | `final String VAR = "value";` | Hằng số |
| `unset VAR` | `var = null;` | Xóa biến |
| `$1`, `$2`, `$@` | `args[0]`, `args[1]`, `args` | Command line arguments |
| `$#` | `args.length` | Số lượng arguments |
| `$0` | `ClassName.class.getName()` | Tên script/program |

### 💡 **Lưu ý quan trọng:**
```bash
# ❌ SAI - có space
VAR = "hello"

# ✅ ĐÚNG - không có space
VAR="hello"

# Sử dụng biến
echo $VAR        # hello
echo ${VAR}      # hello (khuyến nghị - rõ ràng hơn)
echo "$VAR"      # hello (bảo toàn whitespace)
```

```java
// Java equivalent
String var = "hello";
System.out.println(var);
```

---

## 2️⃣ **Toán tử (Operators)**

### a) **Số học (Numeric Comparison)**

| Bash | Java | Ý nghĩa |
|------|------|---------|
| `-eq` | `==` | Equal |
| `-ne` | `!=` | Not equal |
| `-lt` | `<` | Less than |
| `-le` | `<=` | Less or equal |
| `-gt` | `>` | Greater than |
| `-ge` | `>=` | Greater or equal |

### b) **Chuỗi (String Comparison)**

| Bash | Java | Ý nghĩa |
|------|------|---------|
| `=` hoặc `==` | `. equals()` | So sánh bằng |
| `!=` | `!str. equals()` | Khác |
| `-z "$VAR"` | `str == null \|\| str.isEmpty()` | Rỗng |
| `-n "$VAR"` | `str != null && ! str.isEmpty()` | Không rỗng |
| `<` | `str. compareTo() < 0` | So sánh thứ tự từ điển |

### c) **Toán học (Arithmetic)**

```bash
# Bash - cần sử dụng (( )) hoặc expr
a=5
b=3
sum=$((a + b))        # 8
diff=$((a - b))       # 2
prod=$((a * b))       # 15
quot=$((a / b))       # 1 (integer division)
mod=$((a % b))        # 2
((a++))               # increment
((a--))               # decrement
```

```java
// Java
int a = 5, b = 3;
int sum = a + b;      // 8
int diff = a - b;     // 2
int prod = a * b;     // 15
int quot = a / b;     // 1
int mod = a % b;      // 2
a++;                  // increment
a--;                  // decrement
```

---

## 3️⃣ **Điều kiện (Conditionals)**

### a) **If-Else**

```bash
# Bash
if [ $x -gt 10 ]; then
    echo "Big"
elif [ $x -eq 10 ]; then
    echo "Equal"
else
    echo "Small"
fi
```

```java
// Java
if (x > 10) {
    System.out.println("Big");
} else if (x == 10) {
    System.out.println("Equal");
} else {
    System.out.println("Small");
}
```

### b) **Switch/Case**

```bash
# Bash
case "$fruit" in
    apple)
        echo "Red or Green"
        ;;
    banana)
        echo "Yellow"
        ;;
    *)
        echo "Unknown"
        ;;
esac
```

```java
// Java
switch (fruit) {
    case "apple":
        System.out. println("Red or Green");
        break;
    case "banana":
        System.out.println("Yellow");
        break;
    default:
        System.out. println("Unknown");
}
```

### c) **Logical Operators**

| Bash | Java | Ý nghĩa |
|------|------|---------|
| `[ cond1 ] && [ cond2 ]` | `cond1 && cond2` | AND |
| `[ cond1 ] \|\| [ cond2 ]` | `cond1 \|\| cond2` | OR |
| `! [ cond ]` | `!cond` | NOT |
| `[[ cond1 && cond2 ]]` | `cond1 && cond2` | AND (extended) |

```bash
# Bash
if [ $x -gt 10 ] && [ $x -lt 20 ]; then
    echo "Between 10 and 20"
fi

# Hoặc dùng [[ ]] (khuyến nghị)
if [[ $x -gt 10 && $x -lt 20 ]]; then
    echo "Between 10 and 20"
fi
```

```java
// Java
if (x > 10 && x < 20) {
    System.out.println("Between 10 and 20");
}
```

---

## 4️⃣ **Vòng lặp (Loops)**

### a) **For Loop**

```bash
# Bash - Style 1: Range
for i in 1 2 3 4 5; do
    echo $i
done

# Style 2: C-style
for ((i=0; i<5; i++)); do
    echo $i
done

# Style 3: Range expansion
for i in {1..5}; do
    echo $i
done

# Style 4: Loop through array
FRUITS=("apple" "banana" "cherry")
for fruit in "${FRUITS[@]}"; do
    echo $fruit
done
```

```java
// Java
for (int i = 0; i < 5; i++) {
    System.out.println(i);
}

String[] fruits = {"apple", "banana", "cherry"};
for (String fruit : fruits) {
    System.out.println(fruit);
}
```

### b) **While / Until**

```bash
# Bash - While
count=1
while [ $count -le 5 ]; do
    echo $count
    ((count++))
done

# Until (ngược lại với while)
count=1
until [ $count -gt 5 ]; do
    echo $count
    ((count++))
done
```

```java
// Java - While
int count = 1;
while (count <= 5) {
    System.out.println(count);
    count++;
}

// Do-While
count = 1;
do {
    System.out.println(count);
    count++;
} while (count <= 5);
```

### c) **Break & Continue**

```bash
# Bash
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        continue  # Skip 5
    fi
    if [ $i -eq 8 ]; then
        break     # Stop at 8
    fi
    echo $i
done
```

```java
// Java
for (int i = 1; i <= 10; i++) {
    if (i == 5) continue;
    if (i == 8) break;
    System. out.println(i);
}
```

---

## 5️⃣ **Function (Hàm)**

```bash
# Bash
greet() {
    local name=$1      # $1 = tham số đầu tiên
    echo "Hello $name"
    return 0           # Return exit code (0-255)
}

# Gọi function
greet "Hoang"

# Function với return value (dùng echo)
add() {
    local sum=$(($1 + $2))
    echo $sum
}

result=$(add 5 3)
echo "Sum: $result"  # Sum: 8
```

```java
// Java
void greet(String name) {
    System.out.println("Hello " + name);
}

int add(int a, int b) {
    return a + b;
}

greet("Hoang");
int result = add(5, 3);
System.out.println("Sum: " + result);
```

### 💡 **Lưu ý:**
- Bash: `return` chỉ trả về exit code (0-255), dùng `echo` để trả về giá trị
- Java: Có kiểu trả về rõ ràng
- Bash: Tham số = `$1, $2, ... ` hoặc `$@` (tất cả)
- Java: Tham số có tên rõ ràng

---

## 6️⃣ **Mảng (Arrays)**

| Bash | Java | Giải thích |
|------|------|------------|
| `ARR=(1 2 3)` | `int[] arr = {1,2,3};` | Khai báo mảng |
| `${ARR[0]}` | `arr[0]` | Truy cập phần tử |
| `${ARR[@]}` | `arr` (trong for-each) | Tất cả phần tử |
| `${#ARR[@]}` | `arr.length` | Độ dài mảng |
| `ARR+=(4)` | ArrayList: `list.add(4)` | Thêm phần tử |
| `unset ARR[1]` | ArrayList: `list.remove(1)` | Xóa phần tử |

```bash
# Bash
FRUITS=("apple" "banana" "cherry")

# Truy cập
echo ${FRUITS[0]}      # apple
echo ${FRUITS[@]}      # apple banana cherry
echo ${#FRUITS[@]}     # 3

# Thêm phần tử
FRUITS+=("orange")

# Lặp mảng
for fruit in "${FRUITS[@]}"; do
    echo $fruit
done

# Lặp với index
for i in "${!FRUITS[@]}"; do
    echo "Index $i: ${FRUITS[$i]}"
done
```

```java
// Java
String[] fruits = {"apple", "banana", "cherry"};

// Truy cập
System.out.println(fruits[0]);     // apple
System.out.println(fruits. length); // 3

// Lặp mảng
for (String fruit : fruits) {
    System.out.println(fruit);
}

// Lặp với index
for (int i = 0; i < fruits.length; i++) {
    System.out.println("Index " + i + ": " + fruits[i]);
}

// ArrayList (dynamic)
List<String> list = new ArrayList<>(Arrays.asList(fruits));
list.add("orange");
```

---

## 7️⃣ **Map / Associative Array (Bash 4+)**

| Bash | Java | Giải thích |
|------|------|------------|
| `declare -A MAP` | `Map<String,String> map = new HashMap<>();` | Khai báo map |
| `MAP[key]=value` | `map.put("key","value");` | Gán giá trị |
| `${MAP[key]}` | `map.get("key")` | Lấy giá trị |
| `${! MAP[@]}` | `map. keySet()` | Lấy tất cả key |
| `${MAP[@]}` | `map.values()` | Lấy tất cả value |
| `${#MAP[@]}` | `map.size()` | Kích thước |
| `unset MAP[key]` | `map.remove("key")` | Xóa key |

```bash
# Bash
declare -A capitals
capitals=(
    ["Vietnam"]="Hanoi"
    ["Japan"]="Tokyo"
    ["USA"]="Washington"
)

# Truy cập
echo ${capitals["Vietnam"]}  # Hanoi

# Lặp qua keys
for country in "${!capitals[@]}"; do
    echo "$country -> ${capitals[$country]}"
done

# Kiểm tra key tồn tại
if [[ -v capitals["Vietnam"] ]]; then
    echo "Vietnam exists"
fi
```

```java
// Java
Map<String,String> capitals = new HashMap<>();
capitals.put("Vietnam", "Hanoi");
capitals.put("Japan", "Tokyo");
capitals. put("USA", "Washington");

// Truy cập
System.out.println(capitals.get("Vietnam"));  // Hanoi

// Lặp qua keys
for (String country : capitals.keySet()) {
    System.out.println(country + " -> " + capitals.get(country));
}

// Kiểm tra key tồn tại
if (capitals.containsKey("Vietnam")) {
    System. out.println("Vietnam exists");
}
```

---

## 8️⃣ **Kiểm tra file / thư mục**

| Bash | Java | Ý nghĩa |
|------|------|---------|
| `[ -f file ]` | `file. isFile()` | Là file |
| `[ -d dir ]` | `file.isDirectory()` | Là thư mục |
| `[ -e path ]` | `file.exists()` | Tồn tại |
| `[ -r file ]` | `file.canRead()` | Có thể đọc |
| `[ -w file ]` | `file. canWrite()` | Có thể ghi |
| `[ -x file ]` | `file.canExecute()` | Có thể thực thi |
| `[ -s file ]` | `file.length() > 0` | Không rỗng |
| `[ !  -e path ]` | `!file.exists()` | Không tồn tại |
| `[ file1 -nt file2 ]` | `file1. lastModified() > file2.lastModified()` | Mới hơn |

```bash
# Bash
FILE="data.txt"

if [ -f "$FILE" ]; then
    echo "$FILE is a file"
fi

if [ -r "$FILE" ] && [ -w "$FILE" ]; then
    echo "$FILE is readable and writable"
fi

if [ !  -e "backup" ]; then
    mkdir backup
fi
```

```java
// Java
File file = new File("data.txt");

if (file.isFile()) {
    System.out.println(file.getName() + " is a file");
}

if (file.canRead() && file.canWrite()) {
    System.out.println(file.getName() + " is readable and writable");
}

File backup = new File("backup");
if (!backup.exists()) {
    backup.mkdir();
}
```

---

## 9️⃣ **Command Substitution**

```bash
# Bash - Gán output của command vào biến
DATE=$(date +%Y%m%d)
echo $DATE  # 20251126

FILES=$(ls *.txt)
echo $FILES

# Dùng trong string
echo "Today is $(date +%A)"

# Cách cũ (backticks) - không khuyến nghị
DATE=`date +%Y%m%d`
```

```java
// Java - Tương đương
LocalDate date = LocalDate.now();
String dateStr = date.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
System. out.println(dateStr);

// Thực thi command
ProcessBuilder pb = new ProcessBuilder("ls", "-la");
Process process = pb.start();
BufferedReader reader = new BufferedReader(
    new InputStreamReader(process. getInputStream())
);
String line;
while ((line = reader.readLine()) != null) {
    System.out.println(line);
}
```

---

## 🔟 **Exit Code & Error Handling**

| Bash | Java | Ý nghĩa |
|------|------|---------|
| `exit 0` | `System.exit(0)` | Thành công |
| `exit 1` | `System.exit(1)` | Lỗi chung |
| `$?` | `process.exitValue()` | Exit code của lệnh trước |
| `set -e` | try-catch | Dừng khi lỗi |
| `set -u` | - | Báo lỗi khi dùng biến chưa khai báo |
| `set -o pipefail` | - | Pipe fails nếu bất kỳ lệnh nào fail |

```bash
# Bash
#!/bin/bash
set -euo pipefail  # Strict mode (khuyến nghị)

# Kiểm tra exit code
cp file.txt backup/
if [ $? -eq 0 ]; then
    echo "Copy successful"
else
    echo "Copy failed"
    exit 1
fi

# Hoặc ngắn gọn hơn
if cp file.txt backup/; then
    echo "Copy successful"
else
    echo "Copy failed"
    exit 1
fi

# Custom error handler
handle_error() {
    echo "Error on line $1"
    exit 1
}
trap 'handle_error $LINENO' ERR
```

```java
// Java
try {
    Files.copy(
        Paths.get("file.txt"),
        Paths.get("backup/file.txt")
    );
    System.out.println("Copy successful");
} catch (IOException e) {
    System.err.println("Copy failed: " + e.getMessage());
    System. exit(1);
}
```

---

## 1️⃣1️⃣ **String Manipulation**

| Bash | Java | Giải thích |
|------|------|------------|
| `${#VAR}` | `str.length()` | Độ dài |
| `${VAR:0:5}` | `str.substring(0, 5)` | Substring |
| `${VAR^^}` | `str.toUpperCase()` | Chữ hoa |
| `${VAR,,}` | `str.toLowerCase()` | Chữ thường |
| `${VAR/old/new}` | `str.replace("old", "new")` | Replace (first) |
| `${VAR//old/new}` | `str.replaceAll("old", "new")` | Replace (all) |
| `${VAR#prefix}` | `str.replaceFirst("^prefix", "")` | Remove prefix |
| `${VAR%suffix}` | `str. replaceFirst("suffix$", "")` | Remove suffix |

```bash
# Bash
TEXT="Hello World"

echo ${#TEXT}           # 11
echo ${TEXT:0:5}        # Hello
echo ${TEXT^^}          # HELLO WORLD
echo ${TEXT,,}          # hello world
echo ${TEXT/World/Bash} # Hello Bash

# Split string
IFS=',' read -ra PARTS <<< "a,b,c"
for part in "${PARTS[@]}"; do
    echo $part
done
```

```java
// Java
String text = "Hello World";

System.out.println(text.length());              // 11
System.out. println(text.substring(0, 5));       // Hello
System.out.println(text.toUpperCase());         // HELLO WORLD
System. out.println(text.toLowerCase());         // hello world
System.out. println(text.replace("World", "Bash")); // Hello Bash

// Split string
String[] parts = "a,b,c".split(",");
for (String part : parts) {
    System.out. println(part);
}
```

---

## 1️⃣2️⃣ **Input/Output & Redirection**

| Bash | Java | Giải thích |
|------|------|------------|
| `echo "text"` | `System.out.println("text")` | In ra stdout |
| `read VAR` | `Scanner. nextLine()` | Đọc input |
| `cmd > file` | `PrintWriter` | Ghi vào file (overwrite) |
| `cmd >> file` | `FileWriter(file, true)` | Append vào file |
| `cmd < file` | `Scanner(new File(file))` | Đọc từ file |
| `cmd 2> error.log` | `System.setErr()` | Redirect stderr |
| `cmd &> all.log` | - | Redirect cả stdout & stderr |

```bash
# Bash
echo "Enter your name:"
read name
echo "Hello $name"

# Redirect output
echo "Log entry" > log.txt      # Overwrite
echo "Another entry" >> log.txt # Append

# Read from file
while IFS= read -r line; do
    echo $line
done < data.txt

# Redirect stderr
ls /nonexistent 2> error.log
```

```java
// Java
Scanner scanner = new Scanner(System.in);
System.out.println("Enter your name:");
String name = scanner.nextLine();
System.out.println("Hello " + name);

// Write to file
PrintWriter writer = new PrintWriter("log.txt");
writer.println("Log entry");
writer.close();

// Append to file
FileWriter fw = new FileWriter("log.txt", true);
fw. write("Another entry\n");
fw.close();

// Read from file
Scanner fileScanner = new Scanner(new File("data.txt"));
while (fileScanner.hasNextLine()) {
    System.out.println(fileScanner.nextLine());
}
fileScanner.close();
```

---

## 1️⃣3️⃣ **Pipes & Chaining Commands**

| Bash | Java | Giải thích |
|------|------|------------|
| `cmd1 \| cmd2` | Stream API | Pipe output |
| `cmd1 && cmd2` | - | Chạy cmd2 nếu cmd1 thành công |
| `cmd1 \|\| cmd2` | - | Chạy cmd2 nếu cmd1 thất bại |
| `cmd1 ; cmd2` | - | Chạy tuần tự |
| `cmd &` | `Thread`, `ExecutorService` | Chạy background |

```bash
# Bash
# Pipe
cat file.txt | grep "error" | wc -l

# Chaining
mkdir backup && cp *.txt backup/

# Fallback
cp file.txt backup/ || echo "Copy failed"

# Background job
long_process. sh &
```

```java
// Java - Stream API (tương tự pipe)
List<String> lines = Files.readAllLines(Paths. get("file.txt"));
long errorCount = lines.stream()
    .filter(line -> line.contains("error"))
    .count();

// Background task
ExecutorService executor = Executors.newSingleThreadExecutor();
executor.submit(() -> {
    // Long running task
});
```

---

## 1️⃣4️⃣ **Debugging & Best Practices**

### a) **Debugging**

```bash
# Bash
#!/bin/bash

# Enable debug mode
set -x  # Print commands before executing
set -v  # Print input lines

# Debug specific section
set -x
# ...  code to debug
set +x

# Show line numbers on error
set -euo pipefail
trap 'echo "Error on line $LINENO"' ERR
```

### b) **Best Practices**

```bash
#!/bin/bash

# ✅ GOOD PRACTICES

# 1.  Strict mode
set -euo pipefail

# 2. Quote variables
echo "${VAR}"    # Not $VAR
echo "${VAR:-default}"  # With default value

# 3. Use [[ ]] instead of [ ]
if [[ $x -gt 10 ]]; then
    echo "OK"
fi

# 4. Use local in functions
my_func() {
    local var="value"  # Not global
}

# 5. Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <arg>"
    exit 1
fi

# 6. Use meaningful names
USER_NAME="hoang"  # Not x or u

# 7. Add comments
# Process user data
process_data() {
    # Implementation
}

# 8. Handle errors
if ! cp file.txt backup/; then
    echo "ERROR: Copy failed" >&2
    exit 1
fi
```

---

## 1️⃣5️⃣ **Ví dụ thực tế**

### **Example 1: Backup Script**

```bash
#!/bin/bash
set -euo pipefail

# Configuration
SOURCE_DIR="/home/user/data"
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${DATE}.tar.gz"

# Function to log
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if source exists
if [ ! -d "$SOURCE_DIR" ]; then
    log "ERROR: Source directory not found"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create backup
log "Starting backup..."
if tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" "$SOURCE_DIR"; then
    log "Backup successful: $BACKUP_FILE"
else
    log "ERROR: Backup failed"
    exit 1
fi

# Keep only last 7 backups
log "Cleaning old backups..."
cd "$BACKUP_DIR"
ls -t backup_*. tar.gz | tail -n +8 | xargs -r rm

log "Backup completed"
```

```java
// Java equivalent
public class BackupScript {
    private static final String SOURCE_DIR = "/home/user/data";
    private static final String BACKUP_DIR = "/backup";
    
    public static void main(String[] args) {
        try {
            String date = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String backupFile = "backup_" + date + ".tar.gz";
            
            log("Starting backup...");
            
            // Create backup
            ProcessBuilder pb = new ProcessBuilder(
                "tar", "-czf", 
                BACKUP_DIR + "/" + backupFile, 
                SOURCE_DIR
            );
            
            Process process = pb.start();
            int exitCode = process.waitFor();
            
            if (exitCode == 0) {
                log("Backup successful: " + backupFile);
            } else {
                log("ERROR: Backup failed");
                System.exit(1);
            }
            
            // Cleanup old backups
            cleanupOldBackups();
            log("Backup completed");
            
        } catch (Exception e) {
            log("ERROR: " + e.getMessage());
            System. exit(1);
        }
    }
    
    private static void log(String message) {
        String timestamp = LocalDateTime.now()
            .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        System.out.println("[" + timestamp + "] " + message);
    }
    
    private static void cleanupOldBackups() throws IOException {
        // Implementation... 
    }
}
```

### **Example 2: Process Monitor**

```bash
#!/bin/bash

# Check if process is running
check_process() {
    local process_name=$1
    
    if pgrep -x "$process_name" > /dev/null; then
        echo "$process_name is running"
        return 0
    else
        echo "$process_name is NOT running"
        return 1
    fi
}

# Restart process if needed
ensure_running() {
    local process_name=$1
    local start_command=$2
    
    if !  check_process "$process_name"; then
        echo "Starting $process_name..."
        $start_command &
        sleep 2
        
        if check_process "$process_name"; then
            echo "$process_name started successfully"
        else
            echo "ERROR: Failed to start $process_name"
            exit 1
        fi
    fi
}

# Main
ensure_running "nginx" "systemctl start nginx"
ensure_running "mysql" "systemctl start mysql"
```

### **Example 3: Log Analyzer**

```bash
#!/bin/bash

LOG_FILE="/var/log/app.log"
REPORT_FILE="report_$(date +%Y%m%d).txt"

# Count errors
error_count=$(grep -c "ERROR" "$LOG_FILE")

# Find most common errors
echo "=== Error Analysis ===" > "$REPORT_FILE"
echo "Total errors: $error_count" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "Top 10 errors:" >> "$REPORT_FILE"
grep "ERROR" "$LOG_FILE" | \
    sort | uniq -c | sort -nr | head -10 \
    >> "$REPORT_FILE"

# Find errors in last hour
echo "" >> "$REPORT_FILE"
echo "Errors in last hour:" >> "$REPORT_FILE"
grep "ERROR" "$LOG_FILE" | \
    grep "$(date -d '1 hour ago' '+%Y-%m-%d %H')" \
    >> "$REPORT_FILE"

echo "Report saved to $REPORT_FILE"
```

---

## ✅ **Cheat Sheet - Quick Reference**

```bash
# Variables
VAR="value"
echo ${VAR}

# Conditionals
if [[ condition ]]; then action; fi
[[ $x -gt 10 ]] && echo "Big"

# Loops
for i in {1..5}; do echo $i; done
while [[ condition ]]; do action; done

# Functions
func() { echo $1; }
func "hello"

# Arrays
ARR=(1 2 3)
echo ${ARR[@]}

# Maps
declare -A MAP
MAP[key]=value

# File checks
[[ -f file ]] && echo "exists"

# String ops
${VAR:0:5}      # substring
${VAR//old/new} # replace

# I/O
echo "text" > file
read VAR < file

# Error handling
set -euo pipefail
cmd || exit 1

# Debugging
set -x  # debug mode
```

---

## 📚 **Resources**

- **ShellCheck**: https://www.shellcheck.net/ (linter for bash scripts)
- **Bash Guide**: https://mywiki.wooledge.org/BashGuide
- **Advanced Bash Scripting Guide**: https://tldp.org/LDP/abs/html/

---

## 🎯 **Kết luận**

Với mapping này, bạn có thể:
1. ✅ Hiểu syntax Bash thông qua Java
2. ✅ Viết script automation nhanh chóng
3.  ✅ Debug và maintain bash scripts
4. ✅ Áp dụng best practices ngay lập tức

**Lời khuyên cuối:** Hãy bắt đầu với script nhỏ, test kỹ, và luôn dùng `set -euo pipefail`!  🚀