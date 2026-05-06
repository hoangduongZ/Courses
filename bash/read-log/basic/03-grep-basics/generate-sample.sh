#!/usr/bin/env bash
# Tạo sample log có đủ loại: INFO, WARN, ERROR, từ nhiều service và IP

set -euo pipefail

OUT="$(dirname "$0")/sample-app.log"

cat > "$OUT" << 'LOGEOF'
2026-05-06T08:00:01.123 [INFO] [api-gateway] traceId=a1b2c3d4 userId=101 endpoint=/api/login - Request completed successfully_101
2026-05-06T08:00:02.456 [INFO] [user-service] traceId=b2c3d4e5 userId=202 endpoint=/api/users - Cache hit for key user_session_202
2026-05-06T08:00:03.789 [WARN] [order-service] traceId=c3d4e5f6 userId=303 endpoint=/api/orders - Slow query detected: 2.3s on SELECT * FROM orders
2026-05-06T08:00:04.000 [INFO] [payment-service] traceId=d4e5f6a1 userId=101 endpoint=/api/payments - Payment processed_101
2026-05-06T08:00:05.111 [ERROR] [user-service] traceId=e5f6a1b2 userId=404 endpoint=/api/login - JWT token validation failed: signature expired
2026-05-06T08:00:06.222 [INFO] [api-gateway] traceId=f6a1b2c3 userId=505 endpoint=/api/products - Request completed successfully_505
2026-05-06T08:00:07.333 [WARN] [payment-service] traceId=a1b2c3e4 userId=202 endpoint=/api/checkout - Retry attempt 2/3 for external API call
2026-05-06T08:00:08.444 [INFO] [notification-service] traceId=b2c3d4f5 userId=303 endpoint=/api/users - Background job finished: sent 42 emails
2026-05-06T08:00:09.555 [ERROR] [order-service] traceId=c3d4e5a6 userId=101 endpoint=/api/orders - Connection refused to database: ECONNREFUSED 127.0.0.1:5432
2026-05-06T08:00:10.666 [INFO] [user-service] traceId=d4e5f6b1 userId=202 endpoint=/api/users - New user registered_202
2026-05-06T08:00:11.777 [ERROR] [payment-service] traceId=e5f6a1c2 userId=505 endpoint=/api/payments - HTTP 500 Internal Server Error: payment gateway unreachable
2026-05-06T08:00:12.888 [INFO] [api-gateway] traceId=f6a1b2d3 userId=404 endpoint=/api/orders - Order placed successfully_404
2026-05-06T08:00:13.999 [WARN] [user-service] traceId=a1b2c3f4 userId=101 endpoint=/api/users - High memory usage: 78% of heap used
2026-05-06T08:00:14.000 [INFO] [order-service] traceId=b2c3d4a5 userId=303 endpoint=/api/products - Health check passed_303
2026-05-06T08:00:15.111 [ERROR] [api-gateway] traceId=c3d4e5b6 userId=202 endpoint=/api/login - NullPointerException at OrderService.java:142
2026-05-06T08:00:16.222 [INFO] [payment-service] traceId=d4e5f6c1 userId=505 endpoint=/api/payments - Session refreshed_505
2026-05-06T08:00:17.333 [WARN] [order-service] traceId=e5f6a1d2 userId=404 endpoint=/api/orders - Rate limit approaching: 850/1000 req/min
2026-05-06T08:00:18.444 [INFO] [notification-service] traceId=f6a1b2e3 userId=101 endpoint=/api/users - Cache hit for key user_session_101
2026-05-06T08:00:19.555 [ERROR] [user-service] traceId=a1b2c3a4 userId=303 endpoint=/api/users - Request timeout after 30000ms: upstream not responding
2026-05-06T08:00:20.666 [INFO] [api-gateway] traceId=b2c3d4b5 userId=202 endpoint=/api/products - Request completed successfully_202
2026-05-06T08:00:21.777 [INFO] [order-service] traceId=c3d4e5c6 userId=505 endpoint=/api/orders - Order placed successfully_505
2026-05-06T08:00:22.888 [WARN] [api-gateway] traceId=d4e5f6d1 userId=101 endpoint=/api/checkout - Disk usage at 72% on /data partition
2026-05-06T08:00:23.999 [INFO] [user-service] traceId=e5f6a1e2 userId=404 endpoint=/api/users - Health check passed_404
2026-05-06T08:00:24.000 [ERROR] [order-service] traceId=f6a1b2f3 userId=202 endpoint=/api/orders - Redis cache miss rate exceeded threshold: 85%
2026-05-06T08:00:25.111 [INFO] [payment-service] traceId=a1b2c3b4 userId=303 endpoint=/api/payments - Payment processed_303
LOGEOF

total=$(wc -l < "$OUT")
echo "✅ Đã tạo $OUT với $total dòng log"
echo ""
echo "Thống kê:"
echo "  INFO : $(grep -c '\[INFO\]'  "$OUT")"
echo "  WARN : $(grep -c '\[WARN\]'  "$OUT")"
echo "  ERROR: $(grep -c '\[ERROR\]' "$OUT")"
echo ""
echo "▶  Tiếp theo: bash exercise.sh"
