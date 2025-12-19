#!/usr/bin/env bash
set -euo pipefail

echo "⚙️ Running Ansible playbook..."

ansible-playbook -i ansible/inventories/dev/hosts.ini ansible/playbooks/site.yml

echo "✅ Application deployed via Ansible"
