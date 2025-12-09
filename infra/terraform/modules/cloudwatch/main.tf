locals {
    base_name = "${var.project_name}-${var.environment}"
}

# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
    count = var.enable_alarms ? 1 : 0

    name = "${local.base_name}-alerts"
    tags = merge(
        var.tags,
        {
        Name        = "${local.base_name}-alerts"
        Project     = var.project_name
        Environment = var.environment
        }
    )
}

# SNS email subscription (you must confirm via email once)
resource "aws_sns_topic_subscription" "email" {
    count = var.enable_alarms && length(trim(var.sns_alert_email)) > 0 ? 1 : 0

    topic_arn = aws_sns_topic.alerts[0].arn
    protocol  = "email"
    endpoint  = var.sns_alert_email
}

# Alarm: EC2 instance health (StatusCheckFailed > 0)
resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
    count = var.enable_alarms ? 1 : 0

    alarm_name = "${local.base_name}-ec2-status-check-failed"
    alarm_description = "EC2 instance health (StatusCheckFailed > 0)"
    namespace = "AWS/EC2"
    metric_name = "StatusCheckFailed"
    statistic = "Maximum"
    period = "60"
    evaluation_periods = "2"
    threshold = "0"
    comparison_operator = "GreaterThanThreshold"
    treat_missing_data = "missing"

    dimensions = {
        InstanceId = var.monitor_instance_id
    }

    alarm_actions = [ aws_sns_topic.alerts[0].arn ]
    ok_actions = [ aws_sns_topic.alerts[0].arn ]
}

# Alarm: Synthetic availability from our custom metric (ScientificCalculator/SyntheticAvailablity)
# We expect AVAILABILITY = 1 when OK, 0 when FAIL
resource "aws_cloudwatch_metric_alarm" "synthetic_availability" {
    count = var.enable_alarms ? 1 : 0

    alarm_name = "${local.base_name}-synthetic-availability"
    alarm_description = "Synthetic Availability for Scientific Calculator frontend is below 100% in ${var.environment}"
    namespace = "ScientificCalculator"
    metric_name = "SyntheticAvailablity"
    statistic = "Average"
    period = 300 # 5 minutes (matches our cron)
    evaluation_periods = 2 # 10 minutes of failed checks
    threshold = 0.99 # if average drops below 0.99
    comparison_operator = "LessThanThreshold"
    treat_missing_data = "breaching" # missing data treated as failure

    alarm_actions = [ aws_sns_topic.alerts[0].arn ]
    ok_actions = [ aws_sns_topic.alerts[0].arn ]
}
