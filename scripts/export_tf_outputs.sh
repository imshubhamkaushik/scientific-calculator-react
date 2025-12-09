#!/usr/bin/env bash

# scripts/export_tf_outputs.sh
# Export Terraform outputs for a given environment to a JSON file

set -euo pipefail

ENVIRONMENT="${1:-dev}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TERRAFORM_ENV_DIR="${REPO_ROOT}/infra/terraform/envs/${ENVIRONMENT}"

OUTPUT_FILE="${TERRAFORM_ENV_DIR}/terraform-outputs-${ENVIRONMENT}.json"

echo "📤 Exporting Terraform outputs (env: ${ENVIRONMENT})"
echo "📁 Terraform env dir: ${TERRAFORM_ENV_DIR}"
echo "📄 Output file: ${OUTPUT_FILE}"

if [[ ! -d "${TERRAFORM_ENV_DIR}" ]]; then
  echo "❌ Terraform env directory not found: ${TERRAFORM_ENV_DIR}"
  exit 1
fi

command -v terraform >/dev/null 2>&1 || { echo "❌ terraform not found in PATH"; exit 1; }

terraform -chdir="${TERRAFORM_ENV_DIR}" output -json > "${OUTPUT_FILE}"

echo "✅ Terraform outputs exported to: ${OUTPUT_FILE}"
