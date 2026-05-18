#!/usr/bin/env bash
# Bài tập nhận dạng severity level từ nhiều format log khác nhau

set -euo pipefail

SAMPLE="$(dirname "$0")/sample-mixed-format.log"

# Tạo sample log với nhiều format
cat > "$SAMPLE" << 'EOF'
May  6 09:00:01 webserver sshd[1234]: Accepted publickey for ubuntu
May  6 09:00:05 webserver kernel: Out of memory: Killed process 9876 (java)
May  6 09:00:10 webserver CRON[2345]: (root) CMD (/usr/bin/backup.sh)
2026-05-06 09:01:00.123 ERROR 1234 --- [main] c.e.PaymentService : Connection timeout to payment gateway
2026-05-06 09:01:01.456 WARN  1234 --- [main] c.e.CacheService  : Cache miss rate high: 82%
2026-05-06 09:01:02.789 INFO  1234 --- [main] c.e.UserService   : User 42 logged in successfully
2026-05-06 09:01:03.000 DEBUG 1234 --- [main] c.e.OrderService  : Entering method createOrder with params={userId:42}
2026/05/06 09:02:00 [error] 1234#0: *42 connect() failed (111: Connection refused) while connecting to upstream
2026/05/06 09:02:01 [warn]  1234#0: *43 upstream response time 3.142 seconds
2026/05/06 09:02:02 [info]  1234#0: *44 client connected
{"timestamp":"2026-05-06T09:03:00Z","level":"CRITICAL","service":"db-proxy","message":"Primary database unreachable, failover initiated"}
{"timestamp":"2026-05-06T09:03:01Z","level":"INFO","service":"db-proxy","message":"Connected to replica database successfully"}
{"timestamp":"2026-05-06T09:03:02Z","level":"ERROR","service":"api","message":"Unhandled exception in request handler","error":"NullPointerException"}
EOF

pass=0
total=0

check() {
    local q="$1" cmd="$2" expected="$3"
    ((total++))
    actual=$(eval "$cmd" 2>/dev/null | head -1 || echo "")
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Q$total: $q"
    if [[ "$actual" == *"$expected"* ]]; then
        echo "   ✅ Match: $actual"
        ((pass++))
    else
        echo "   ❌ Kết quả: $actual"
        echo "   💡 Cần chứa: $expected"
    fi
    echo ""
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║    EXERCISE: Nhận dạng severity levels   ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Sample log: $SAMPLE"
echo ""

# Xem toàn bộ trước
echo "=== Nội dung sample log ==="
cat -n "$SAMPLE"
echo ""

echo "=== Câu hỏi ==="
echo ""

check \
    "Tìm tất cả dòng level CRITICAL (bất kỳ format nào)" \
    "grep -iE 'CRITICAL|EMERG|ALERT' $SAMPLE" \
    "CRITICAL"

check \
    "Tìm dòng lỗi liên quan đến database/connection" \
    "grep -iE 'database|connection refused|connect.*failed' $SAMPLE | head -1" \
    ""

check \
    "Đếm tổng số dòng có vấn đề (ERROR + WARN + CRITICAL)" \
    "grep -ciE '\[?ERROR\]?|\[?WARN(ING)?\]?|\[?CRITICAL\]?' $SAMPLE" \
    ""

# Manual quiz
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Q4 (tự trả lời): Nhìn vào dòng syslog:"
echo "  'kernel: Out of memory: Killed process 9876'"
echo "  → Level này tương đương gì trong RFC 5424?"
echo "  → Cần xử lý ngay không?"
echo ""
echo "  Đáp án: CRITICAL (level 2) — OOM killer = hệ thống hết RAM,"
echo "  cần xử lý ngay, thêm RAM hoặc tìm process nào gây rò rỉ bộ nhớ."
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Kết quả auto-check: ✅ $pass / $total"
echo ""
echo "=== Tổng kết Basic Checklist ==="
echo ""
echo "  ✅ 01 - Biết vị trí file log trong /var/log/"
echo "  ✅ 02 - Dùng tail -f theo dõi log realtime"
echo "  ✅ 03 - Dùng grep tìm lỗi cơ bản"
echo "  ✅ 04 - Hiểu log severity levels"
echo ""
echo "🎉 Hoàn thành Basic level!"
echo "   Khi cần lên Intermediate, yêu cầu tạo module tiếp theo."
