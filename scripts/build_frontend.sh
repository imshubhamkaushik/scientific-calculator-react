#!/usr/bin/env bash

# scripts/build_frontend.sh
# Build script for React Scientific Calculator frontend


set -euo pipefail

# Optional build mode argument (not strictly needed for React, but nice to have)
BUILD_ENV="${1:-production}"

# Resolve repo root (directory containing this script's parent)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FRONTEND_DIR="${REPO_ROOT}"
BUILD_DIR="${REPO_ROOT}/build"

echo "Build frontend (env: ${BUILD_ENV})"
echo "Repo root: ${REPO_ROOT}"
echo "Frontend dir: ${FRONTEND_DIR}"

if [[ ! -d "${FRONTEND_DIR}" ]]; then
  echo "Frontend directory not found: ${FRONTEND_DIR}"
  exit 1
fi

cd "${FRONTEND_DIR}"

# Install dependencies (prefer npm ci for reproducible builds)
if [[ -f "package-lock.json" ]]; then
  echo "Found package-lock.json. Installing dependencies with npm ci..."
  npm ci
else
  echo "No package-lock.json found. Installing dependencies with npm install..."
  npm install
fi

echo "Dependencies installed."

# Run tests Optional
if npm run | grep -qE '^[[:space:]]*test'; then
  echo "Running tests..."
  npm test -- --watch=false || {
    echo "Tests failed."
    exit 1
  }
  echo "Tests passed."
else
  echo "No test script found in package.json, skipping tests."
fi

# Build the app
echo "Building React app (npm run build)..."
NODE_ENV="${BUILD_ENV}" npm run build

if [[ ! -d "${BUILD_DIR}" ]]; then
  echo "Build directory not found: ${BUILD_DIR}"
  exit 1
fi

echo "Frontend Build completed. Build directory: ${BUILD_DIR}"