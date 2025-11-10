#!/usr/bin/env bash
set -euo pipefail
cd terraform/envs/dev
terraform init
terraform apply -auto-approve