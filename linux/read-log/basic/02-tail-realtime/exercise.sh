#!/usr/bin/env bash
# Bài tập tail -f — tạo snapshot rồi kiểm tra kỹ năng

set -euo pipefail

LOG_FILE="/tmp/practice-app.log"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "❌ Chưa có log file. Chạy 'bash simulate-log.sh' ở terminal khác trước."
    exit 1
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║      EXERCISE: tail -f practice          ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Dùng log file: $LOG_FILE"
echo ""

total=$(wc -l < "$LOG_FILE")
errors=$(grep -c "\[ERROR\]" "$LOG_FILE" 2>/dev/null || echo 0)
warns=$(grep -c "\[WARN\]" "$LOG_FILE" 2>/dev/null || echo 0)
infos=$(grep -c "\[INFO\]" "$LOG_FILE" 2>/dev/null || echo 0)

echo "=== Thống kê hiện tại ==="
echo "  Tổng dòng : $total"
echo "  ERROR     : $errors"
echo "  WARN      : $warns"
echo "  INFO      : $infos"
echo ""

echo "=== Câu hỏi thực hành ==="
echo ""
echo "1. Hiện 20 dòng cuối của log:"
echo "   → Lệnh: tail -n 20 $LOG_FILE"
echo ""
echo "2. Chỉ xem dòng ERROR trong log (không follow):"
echo "   → Lệnh: grep '\[ERROR\]' $LOG_FILE"
echo ""
echo "3. Follow log và lọc chỉ ERROR + WARN:"
echo "   → Lệnh: tail -f $LOG_FILE | grep -E '\[ERROR\]|\[WARN\]'"
echo ""
echo "4. Follow log nhiều service cùng lúc (giả lập):"
echo "   → Lệnh: tail -f $LOG_FILE | grep 'payment-service'"
echo ""

echo "=== Auto-check ==="
echo ""

pass=0

# Check 1: có thể tail không
result=$(tail -n 5 "$LOG_FILE" | wc -l)
if (( result >= 1 )); then
    echo "✅ tail -n 5 hoạt động: lấy được $result dòng"
    ((pass++))
fi

# Check 2: grep ERROR
if grep -q "\[ERROR\]" "$LOG_FILE"; then
    count=$(grep -c "\[ERROR\]" "$LOG_FILE")
    echo "✅ Có $count dòng ERROR trong log — grep hoạt động tốt"
    echo "   Ví dụ: $(grep '\[ERROR\]' "$LOG_FILE" | tail -1)"
    ((pass++))
else
    echo "ℹ️  Chưa có dòng ERROR (log còn ít, chờ simulate-log.sh thêm)"
fi

# Check 3: nhiều file (demo với cùng file)
line_count=$(tail -n 1 "$LOG_FILE" | wc -c)
if (( line_count > 0 )); then
    echo "✅ File log không rỗng — sẵn sàng để tail -f"
    ((pass++))
fi

echo ""
echo "Kết quả: ✅ $pass/3 check passed"
echo ""
echo "▶  Tiếp theo: cd ../03-grep-basics && bash exercise.sh"
