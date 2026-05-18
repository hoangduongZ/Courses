#!/usr/bin/env bash
# Bài tập: xác định file log theo tình huống

set -euo pipefail

FAKE_LOG_DIR="$(dirname "$0")/fake-var-log"

if [[ ! -d "$FAKE_LOG_DIR" ]]; then
    echo "❌ Chưa có môi trường mô phỏng. Chạy 'bash explore.sh' trước."
    exit 1
fi

pass=0
fail=0

check() {
    local q="$1" expected_file="$2" grep_pattern="$3"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❓ $q"
    echo "   File: $FAKE_LOG_DIR/$expected_file"
    echo ""

    if grep -q "$grep_pattern" "$FAKE_LOG_DIR/$expected_file" 2>/dev/null; then
        echo "   ✅ Tìm thấy bằng chứng: $(grep "$grep_pattern" "$FAKE_LOG_DIR/$expected_file" | head -1)"
        ((pass++))
    else
        echo "   ❌ Không tìm thấy pattern '$grep_pattern' trong file này"
        ((fail++))
    fi
    echo ""
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  EXERCISE: Đọc đúng file cho đúng tình huống ║"
echo "╚══════════════════════════════════════════╝"
echo ""

check \
    "Tình huống: Có IP lạ thử login SSH liên tục → đọc file nào?" \
    "auth.log" \
    "Failed password"

check \
    "Tình huống: Web API trả lỗi 500 → đọc file nào?" \
    "nginx/error.log" \
    "error"

check \
    "Tình huống: Server bị OOM (out of memory) → đọc file nào?" \
    "kern.log" \
    "Out of memory"

check \
    "Tình huống: Cron job có chạy không → đọc file nào?" \
    "cron" \
    "CMD"

check \
    "Tình huống: Ai đó dùng sudo lệnh gì → đọc file nào?" \
    "auth.log" \
    "sudo"

check \
    "Tình huống: Package nào bị xóa hôm nay → đọc file nào?" \
    "dpkg.log" \
    "remove"

check \
    "Tình huống: IP 45.33.32.156 đang scan gì trên web → đọc file nào?" \
    "nginx/access.log" \
    "45.33.32.156"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Kết quả: ✅ $pass / $((pass + fail)) câu đúng"
echo ""
echo "▶  Tiếp theo: cd ../02-tail-realtime && bash README.md"
