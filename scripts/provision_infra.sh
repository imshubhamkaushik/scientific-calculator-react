#!/usr/bin/env bash

# scripts/provision_infra.sh
# Wrapper around Terraform init/plan/apply for a given environment

set -euo pipefail

ENVIRONMENT="${1:-dev}"
ACTION="${2:-apply}"   # plan | apply

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TERRAFORM_ENV_DIR="${REPO_ROOT}/infra/terraform/envs/${ENVIRONMENT}"

echo "🏗  Provisioning infrastructure (env: ${ENVIRONMENT}, action: ${ACTION})"
echo "📁 Terraform env dir: ${TERRAFORM_ENV_DIR}"

if [[ ! -d "${TERRAFORM_ENV_DIR}" ]]; then
  echo "❌ Terraform env directory not found: ${TERRAFORM_ENV_DIR}"
  exit 1
fi

command -v terraform >/dev/null 2>&1 || { echo "❌ terraform not found in PATH"; exit 1; }

echo "⚙️  Running terraform init..."
terraform -chdir="${TERRAFORM_ENV_DIR}" init -input=false

case "${ACTION}" in
  plan)
    echo "📋 Running terraform plan..."
    terraform -chdir="${TERRAFORM_ENV_DIR}" plan
    ;;
  apply)
    echo "✅ Running terraform apply (auto-approve)..."
    terraform -chdir="${TERRAFORM_ENV_DIR}" apply -auto-approve
    ;;
  *)
    echo "❌ Unknown action '${ACTION}'. Use 'plan' or 'apply'."
    exit 1
    ;;
esac

echo "🎉 Terraform ${ACTION} completed for env: ${ENVIRONMENT}"
