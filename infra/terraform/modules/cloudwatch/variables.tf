variable "project_name" {
    description = "Project name used for naming resources"
    type        = string
}

variable "environment" {
    description = "Deployment environment (e.g., dev, prod)"
    type        = string  
}

variable "monitor_instance_id" {
    description = "EC2 instance ID for the monitor/bastion instance"
    type        = string
}

variable "sns_alert_email" {
    description = "SNS topic ARN to send alerts to"
    type        = string
}

variable "enable_alarms" {
    description = "Enable CloudWatch alarms for the monitor instance"
    type        = bool
    default     = true
}

variable "tags" {
    description = "Tags to apply to resources"
    type        = map(string)
    default     = {}
}