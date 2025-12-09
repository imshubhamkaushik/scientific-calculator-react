output "vpc_id" {
  description = "VPC ID for dev environment"
  value       = module.network.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID for dev environment"
  value       = module.network.public_subnet_id
}

output "frontend_bucket_name" {
  description = "S3 bucket name where frontend is hosted"
  value       = module.s3_cloudfront.bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.s3_cloudfront.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.s3_cloudfront.cloudfront_domain_name
}

output "monitor_instance_id" {
  description = "ID of the monitor EC2 instance"
  value       = module.ec2_monitor.instance_id
}

output "monitor_public_ip" {
  description = "Public IP of the monitor EC2 instance"
  value       = module.ec2_monitor.public_ip
}

output "monitor_public_dns" {
  description = "Public DNS of the monitor EC2 instance"
  value       = module.ec2_monitor.public_dns
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = module.cloudwatch.sns_topic_arn
}
