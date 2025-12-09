output "sns_topic_arn" {
    description = "ARN of the SNS topic"
    value = var.enable_alarms ? aws_sns_topic.alerts[0].arn : null
}