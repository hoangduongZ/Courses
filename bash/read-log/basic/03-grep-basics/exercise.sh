#!/usr/bin/env bash
# Bài tập grep — tự làm trước, rồi script tự kiểm tra

set -euo pipefail

LOG="$(dirname "$0")/sample-app.log"

if [[ ! -f "$LOG" ]]; then
    echo "❌ Chưa có sample log. Chạy 'bash generate-sample.sh' trước."
    exit 1
fi

pass=0
total=0

run_check() {
    local desc="$1"
    local expected="$2"
    local cmd="$3"

    ((total++))
    actual=$(eval "$cmd" 2>/dev/null || echo "")

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Q$total: $desc"
    echo "   Lệnh : $cmd"

    if [[ "$actual" == "$expected" ]]; then
        echo "   ✅ Kết quả: $actual"
        ((pass++))
    else
        echo "   ❌ Kết quả nhận: '$actual'"
        echo "   💡 Đáp án đúng : '$expected'"
    fi
    echo ""
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║       EXERCISE: grep basics              ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Trả lời bằng cách sửa lệnh trong file này hoặc chạy tay từng lệnh."
echo "Script sẽ tự kiểm tra kết quả."
echo ""

run_check \
    "Đếm tổng số dòng ERROR trong log" \
    "5" \
    "grep -c '\[ERROR\]' $LOG"

run_check \
    "Đếm tổng số dòng WARN trong log" \
    "5" \
    "grep -c '\[WARN\]' $LOG"

run_check \
    "Tìm service nào gây ra lỗi 'database' (in tên service)" \
    "order-service" \
    "grep 'database' $LOG | grep -o '\[order-service\]' | tr -d '[]' | head -1"

run_check \
    "Đếm bao nhiêu lần userId=101 xuất hiện trong log" \
    "5" \
    "grep -c 'userId=101' $LOG"

run_check \
    "Tìm dòng có lỗi 'timeout' (case-insensitive)" \
    "1" \
    "grep -ic 'timeout' $LOG"

run_check \
    "Lấy dòng ERROR đầu tiên, in ra traceId của nó" \
    "e5f6a1b2" \
    "grep '\[ERROR\]' $LOG | head -1 | grep -o 'traceId=[a-z0-9]*' | cut -d= -f2"

run_check \
    "Đếm số dòng KHÔNG phải INFO (WARN + ERROR)" \
    "10" \
    "grep -vc '\[INFO\]' $LOG"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Kết quả: ✅ $pass / $total câu đúng"
echo ""

if (( pass == total )); then
    echo "🎉 Hoàn hảo! Bạn nắm vững grep cơ bản."
elif (( pass >= total * 6 / 10 )); then
    echo "👍 Khá tốt. Xem lại các câu sai và thử lại."
else
    echo "📖 Ôn lại README.md rồi thử lại."
fi

echo ""
echo "▶  Tiếp theo: cd ../04-severity-levels && bash exercise.sh"
