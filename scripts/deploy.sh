#!/usr/bin/env bash
set -euo pipefail

echo "🔄 Starting full deployment pipeline..."

./scripts/build.sh
./scripts/terraform_apply.sh
./scripts/ansible_deploy.sh

echo "🎉 Deployment completed successfully"
