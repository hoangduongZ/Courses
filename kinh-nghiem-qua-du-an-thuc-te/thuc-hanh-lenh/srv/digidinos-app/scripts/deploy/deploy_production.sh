#!/bin/bash
set -e

APP_DIR="/srv/digidinos-app"
BACKUP_DIR="/opt/backups/daily"
ENV_FILE="$APP_DIR/backend/config/production.env"

echo "[deploy] Starting deployment — $(date)"
echo "[deploy] Pulling latest code..."
cd $APP_DIR && git pull origin main

echo "[deploy] Installing dependencies..."
cd backend && npm ci --production

echo "[deploy] Backing up current build..."
tar -czf "$BACKUP_DIR/pre_deploy_$(date +%Y%m%d_%H%M%S).tar.gz" $APP_DIR/backend/dist

echo "[deploy] Restarting service..."
systemctl restart digidinos-app

echo "[deploy] Done — $(date)"
