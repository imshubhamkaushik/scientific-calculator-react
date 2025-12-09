output "instance_id" {
  description = "ID of the EC2 monitor instance"
  value       = aws_instance.monitor.id
}

output "public_ip" {
  description = "Public IP of the EC2 monitor instance"
  value       = aws_instance.monitor.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 monitor instance"
  value       = aws_instance.monitor.public_dns
}

output "security_group_id" {
  description = "Security group ID for the monitor instance"
  value       = aws_security_group.monitor_sg.id
}

output "iam_role_name" {
  description = "IAM role name attached to the monitor instance"
  value       = aws_iam_role.monitor_role.name
}

output "iam_role_arn" {
  description = "IAM role ARN attached to the monitor instance"
  value       = aws_iam_role.monitor_role.arn
}