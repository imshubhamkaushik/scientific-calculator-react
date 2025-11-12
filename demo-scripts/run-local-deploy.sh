#!/usr/bin/env bash
set -euo pipefail

BUCKET=${1:-""}
if [ -z "$BUCKET" ]; then
  echo "Usage: $0 <S3_BUCKET_NAME>"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Build frontend from repo root
echo "Building app..."
cd "$ROOT_DIR"
npm ci
npm run build

# Sync to S3 (build/ is created in repo root) 
echo "Syncing build/ to s3://$BUCKET ..."
aws s3 sync build/ "s3://$BUCKET" --acl public-read --delete

echo "Done. If you use CloudFront, create an invalidation to refresh cache (or wait)."

# Optional: detect simple backend presence under src/ (common paths)
if [ -d|"$ROOT_DIR/src/server" ] || [ -d|"$ROOT_DIR/src/backend" ] || [ -d|"$ROOT_DIR/src/api" ]; then
  echo "Backend code detected under src/, please use Ansible/Jenkins to deploy backend instance (if provisioned)."
else
  echo "No backend folder detected under src/ (src/server, src/backend, src/api)."
fi