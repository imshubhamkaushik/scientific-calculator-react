#!/usr/bin/env bash
set -euo pipefail

APP_URL="${1:?Usage: ./health_check.sh <APP_URL>}"

echo "🔍 Checking application health at $APP_URL..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL")

if [[ "$HTTP_STATUS" -eq 200 ]]; then
  echo "✅ Application is healthy"
else
  echo "❌ Application health check failed (HTTP $HTTP_STATUS)"
  exit 1
fi
echo "🎉 Health check completed successfully"