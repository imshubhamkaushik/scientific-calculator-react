#!/usr/bin/env bash

# scripts/configure_ec2.sh
# Configure monitor EC2 via Ansible using Terraform outputs (monitor_public_dns)

set -euo pipefail

ENVIRONMENT="${1:-dev}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TERRAFORM_ENV_DIR="${REPO_ROOT}/infra/terraform/envs/${ENVIRONMENT}"
ANSIBLE_DIR="${REPO_ROOT}/ansible"

echo "🧩 Configuring monitor EC2 with Ansible (env: ${ENVIRONMENT})"
echo "📁 Terraform env dir: ${TERRAFORM_ENV_DIR}"
echo "📁 Ansible dir: ${ANSIBLE_DIR}"

if [[ ! -d "${TERRAFORM_ENV_DIR}" ]]; then
  echo "❌ Terraform env directory not found: ${TERRAFORM_ENV_DIR}"
  exit 1
fi

if [[ ! -d "${ANSIBLE_DIR}" ]]; then
  echo "❌ Ansible directory not found: ${ANSIBLE_DIR}"
  exit 1
fi

command -v terraform >/dev/null 2>&1 || { echo "❌ terraform not found in PATH"; exit 1; }
command -v ansible-playbook >/dev/null 2>&1 || { echo "❌ ansible-playbook not found in PATH"; exit 1; }

# Require SSH key path
if [[ -z "${ANSIBLE_SSH_KEY_PATH:-}" ]]; then
  echo "❌ Environment variable ANSIBLE_SSH_KEY_PATH is not set."
  echo "   Export it, e.g.: export ANSIBLE_SSH_KEY_PATH=~/.ssh/your-key.pem"
  exit 1
fi

if [[ ! -f "${ANSIBLE_SSH_KEY_PATH}" ]]; then
  echo "❌ SSH key file not found at ${ANSIBLE_SSH_KEY_PATH}"
  exit 1
fi

echo "📤 Fetching monitor_public_dns from Terraform outputs..."
MONITOR_DNS="$(
  terraform -chdir="${TERRAFORM_ENV_DIR}" output -raw monitor_public_dns
)"

if [[ -z "${MONITOR_DNS}" ]]; then
  echo "❌ monitor_public_dns output is empty. Did you run terraform apply?"
  exit 1
fi

echo "✅ Monitor EC2 DNS: ${MONITOR_DNS}"

TEMP_INVENTORY="$(mktemp /tmp/ansible-inventory-${ENVIRONMENT}-XXXX.ini)"

cat > "${TEMP_INVENTORY}" <<EOF
[monitor]
monitor-ec2 ansible_host=${MONITOR_DNS}

[monitor:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=${ANSIBLE_SSH_KEY_PATH}
ansible_python_interpreter=/usr/bin/python3
EOF

echo "📄 Generated temporary inventory: ${TEMP_INVENTORY}"
cat "${TEMP_INVENTORY}"

echo "▶️ Running Ansible playbook..."
ansible-playbook \
  -i "${TEMP_INVENTORY}" \
  "${ANSIBLE_DIR}/playbooks/site.yml"

echo "🧹 Cleaning up temporary inventory..."
rm -f "${TEMP_INVENTORY}"

echo "🎉 Ansible configuration completed for env: ${ENVIRONMENT}"
