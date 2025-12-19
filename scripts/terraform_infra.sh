#!/usr/bin/env bash
set -euo pipefail

cd infra/terraform/env/dev

echo "🚀 Initializing Terraform..."
terraform init

echo "📐 Planning Terraform changes..."
terraform plan -out=tfplan

echo "🛠️ Applying Terraform..."
terraform apply tfplan

echo "✅ Infrastructure provisioned"
