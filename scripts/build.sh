#!/usr/bin/env bash
set -euo pipefail

echo "📦 Building React application..."

npm install
npm run build

echo "✅ Build completed successfully"
