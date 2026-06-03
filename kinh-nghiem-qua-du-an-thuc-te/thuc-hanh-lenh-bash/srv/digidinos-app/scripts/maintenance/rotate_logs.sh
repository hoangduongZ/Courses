#!/bin/bash
# Rotate logs tháng trước sang archived/
LOG_DIR="/var/log/app"
ARCHIVE_DIR="/var/log/app/archived"
LAST_MONTH=$(date -d "last month" +%Y/%m)

echo "[rotate] Archiving logs from $LAST_MONTH..."
find "$LOG_DIR/$LAST_MONTH" -name "*.log" | while read f; do
  gzip "$f" && mv "${f}.gz" "$ARCHIVE_DIR/"
done

echo "[rotate] Removing archives older than 90 days..."
find $ARCHIVE_DIR -name "*.log.gz" -mtime +90 -delete

echo "[rotate] Done"
