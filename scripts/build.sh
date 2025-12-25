#!/usr/bin/env bash
set -euo pipefail

echo "📦 Building React application..."

npm ci
npm run build

echo "✅ Build completed successfully"
