#!/bin/bash
# Chạy mỗi ngày 00:00 — xóa session và cache hết hạn
SESSIONS_DIR="/var/tmp/sessions"
CACHE_DIR="/var/tmp/cache"

echo "[cleanup] Deleting expired sessions..."
find $SESSIONS_DIR -name "*.tmp" -mtime +1 -delete
echo "[cleanup] Deleted $(find $SESSIONS_DIR -name "*.tmp" | wc -l) remaining sessions"

echo "[cleanup] Clearing cache..."
find $CACHE_DIR -name "*.tmp" -delete

echo "[cleanup] Done — $(date)"
