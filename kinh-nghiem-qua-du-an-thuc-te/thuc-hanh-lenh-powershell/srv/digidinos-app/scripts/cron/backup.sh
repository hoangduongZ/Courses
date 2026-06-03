#!/bin/bash
# Chạy mỗi ngày 17:00 — backup database và uploads
BACKUP_DIR="/opt/backups/daily"
DB_NAME="myapp_production"
UPLOADS_DIR="/home/deploy/uploads"
DATE=$(date +%Y%m%d)

echo "[backup] Starting backup — $DATE"

echo "[backup] Dumping database..."
pg_dump -U app_user $DB_NAME | gzip > "$BACKUP_DIR/db_${DATE}.sql.gz"

echo "[backup] Archiving uploads..."
tar -czf "$BACKUP_DIR/uploads_${DATE}.tar.gz" $UPLOADS_DIR

echo "[backup] Removing backups older than 7 days..."
find $BACKUP_DIR -name "*.gz" -mtime +7 -delete

echo "[backup] Done — $(date)"
