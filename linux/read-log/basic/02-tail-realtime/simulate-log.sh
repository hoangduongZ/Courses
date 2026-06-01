#!/usr/bin/env bash
# Mô phỏng log server realtime — chạy terminal riêng, Ctrl+C để dừng

LOG_FILE="/tmp/practice-app.log"
SERVICES=("api-gateway" "user-service" "order-service" "payment-service" "notification-service")
LEVELS=("INFO" "INFO" "INFO" "INFO" "WARN" "ERROR")   # INFO nhiều hơn để thực tế
USERS=(101 202 303 404 505)
ENDPOINTS=("/api/users" "/api/orders" "/api/products" "/api/login" "/api/checkout" "/api/payments")

echo "▶  Log generator khởi động → $LOG_FILE"
echo "   Ctrl+C để dừng"
echo "   Mở terminal khác chạy: tail -f $LOG_FILE"
echo ""

# Tạo/xóa file cũ
> "$LOG_FILE"

# Error scenarios theo kịch bản thực tế
ERROR_MSGS=(
    "Connection refused to database: ECONNREFUSED 127.0.0.1:5432"
    "Request timeout after 30000ms: upstream not responding"
    "NullPointerException at OrderService.java:142"
    "HTTP 500 Internal Server Error: payment gateway unreachable"
    "Redis cache miss rate exceeded threshold: 85%"
    "JWT token validation failed: signature expired"
)

WARN_MSGS=(
    "High memory usage: 78% of heap used"
    "Slow query detected: 2.3s on SELECT * FROM orders"
    "Retry attempt 2/3 for external API call"
    "Rate limit approaching: 850/1000 req/min"
    "Disk usage at 72% on /data partition"
)

INFO_MSGS=(
    "Request completed successfully"
    "Cache hit for key user_session_"
    "Background job finished: sent 42 emails"
    "Health check passed"
    "New user registered"
    "Order placed successfully"
    "Payment processed"
    "Session refreshed"
)

counter=0
while true; do
    ts=$(date '+%Y-%m-%dT%H:%M:%S.%3N')
    svc=${SERVICES[$((RANDOM % ${#SERVICES[@]}))]}
    level_idx=$((RANDOM % ${#LEVELS[@]}))
    level=${LEVELS[$level_idx]}
    user=${USERS[$((RANDOM % ${#USERS[@]}))]}
    endpoint=${ENDPOINTS[$((RANDOM % ${#ENDPOINTS[@]}))]}
    trace="$(cat /dev/urandom | LC_ALL=C tr -dc 'a-f0-9' 2>/dev/null | head -c 8)"

    case "$level" in
        ERROR)
            msg=${ERROR_MSGS[$((RANDOM % ${#ERROR_MSGS[@]}))]}
            ;;
        WARN)
            msg=${WARN_MSGS[$((RANDOM % ${#WARN_MSGS[@]}))]}
            ;;
        *)
            msg=${INFO_MSGS[$((RANDOM % ${#INFO_MSGS[@]}))]}"_${user}"
            ;;
    esac

    echo "$ts [$level] [$svc] traceId=$trace userId=$user endpoint=$endpoint - $msg" >> "$LOG_FILE"

    # In ra màn hình để biết đang chạy
    case "$level" in
        ERROR) printf "\033[31m%s [%s] %s\033[0m\n" "$ts" "$level" "$msg" ;;
        WARN)  printf "\033[33m%s [%s] %s\033[0m\n" "$ts" "$level" "$msg" ;;
        *)     printf "%s [%s] %s\n" "$ts" "$level" "$msg" ;;
    esac

    ((counter++))
    if (( counter % 20 == 0 )); then
        echo "--- $counter dòng đã ghi vào $LOG_FILE ---"
    fi

    # Random delay 0.3s - 1.5s để thực tế hơn
    sleep "$(echo "scale=1; $(( (RANDOM % 12) + 3 )) / 10" | bc)"
done
