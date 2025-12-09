#!/usr/bin/env bash

# scripts/deploy_frontend.sh
# Deploy built React app to S3 + invalidate CloudFront, using Terraform outputs

set -euo pipefail

ENVIRONMENT="${1:-dev}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

FRONTEND_DIR="${REPO_ROOT}"
BUILD_DIR="${FRONTEND_DIR}/build"
TERRAFORM_ENV_DIR="${REPO_ROOT}/infra/terraform/envs/${ENVIRONMENT}"

echo "Deploying frontend (env: ${ENVIRONMENT})"
echo "Repo root: ${REPO_ROOT}"
echo "Terraform env dir: ${TERRAFORM_ENV_DIR}"
echo "Build dir: ${BUILD_DIR}"

# Basic checks
if [[ ! -d "${BUILD_DIR}" ]]; then
  echo "Build directory not found at ${BUILD_DIR}."
  echo "Did you run scripts/build_frontend.sh already?"
  exit 1
fi

if [[ ! -d "${TERRAFORM_ENV_DIR}" ]]; then
  echo "Terraform env directory not found at ${TERRAFORM_ENV_DIR}"
  exit 1
fi

# Ensure required tools exist
command -v terraform >/dev/null 2>&1 || { echo "terraform not found in PATH"; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "aws CLI not found in PATH"; exit 1; }

# Get S3 bucket name and CloudFront distribution ID from Terraform outputs
echo "Fetching Terraform outputs..."

FRONTEND_BUCKET_NAME="$(
  terraform -chdir="${TERRAFORM_ENV_DIR}" output -raw frontend_bucket_name
)"

CLOUDFRONT_DISTRIBUTION_ID="$(
  terraform -chdir="${TERRAFORM_ENV_DIR}" output -raw cloudfront_distribution_id
)"

CLOUDFRONT_DOMAIN_NAME="$(
  terraform -chdir="${TERRAFORM_ENV_DIR}" output -raw cloudfront_domain_name
)"

if [[ -z "${FRONTEND_BUCKET_NAME}" || -z "${CLOUDFRONT_DISTRIBUTION_ID}" ]]; then
  echo "Failed to read required Terraform outputs."
  echo "frontend_bucket_name: '${FRONTEND_BUCKET_NAME}'"
  echo "cloudfront_distribution_id: '${CLOUDFRONT_DISTRIBUTION_ID}'"
  exit 1
fi

echo "Terraform outputs:"
echo "S3 Bucket: ${FRONTEND_BUCKET_NAME}"
echo "CloudFront Distribution ID: ${CLOUDFRONT_DISTRIBUTION_ID}"
echo "CloudFront Domain: ${CLOUDFRONT_DOMAIN_NAME}"

# Sync build/ to S3
echo "Uploading build/ to s3://${FRONTEND_BUCKET_NAME} ..."
aws s3 sync "${BUILD_DIR}/" "s3://${FRONTEND_BUCKET_NAME}/" --delete

echo "S3 sync completed."

# Invalidate CloudFront cache
echo "Creating CloudFront invalidation for /* ..."
INVALIDATION_ID="$(
  aws cloudfront create-invalidation \
    --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}" \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text
)"

echo "Invalidation created. ID: ${INVALIDATION_ID}"
echo "🌐 Your app should be available at: https://${CLOUDFRONT_DOMAIN_NAME}/"

echo "Deployment complete."