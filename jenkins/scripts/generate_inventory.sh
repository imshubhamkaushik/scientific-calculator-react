#!/usr/bin/env bash
set -euo pipefail
ASG_NAME=${1:-backend-asg}
REGION=${2:-ap-south-1}
OUT_INV=${3:-../../ansible/inventory.ini}

INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --region "$REGION" --query 'AutoScalingGroups[0].Instances[*].InstanceId' --output text)
echo "[backend]" > "$OUT_INV"
for id in $INSTANCE_IDS; do
  ip=$(aws ec2 describe-instances --instance-ids $id --region "$REGION" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
  echo "$ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/<YOUR_KEY_FILE> db_host=${DB_HOST} db_user=${DB_USER} db_password=${DB_PASSWORD} db_name=${DB_NAME}" >> "$OUT_INV"
done
echo "Inventory written to $OUT_INV"
