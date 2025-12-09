variable "aws_region" {
    description = "AWS Region"  
    type        = string
    default     = "us-east-1"
}

variable "project_name" {
    description = "Project name used for naming resources"
    type        = string
    default = "scientific-calculator-react"
}

variable "environment" {
    description = "Deployment environment (e.g., dev, prod)"
    type        = string
    default     = "dev"
}

variable "vpc_cidr" {
    description = "CIDR Block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR Block for the Public Subnet"
    type        = string
    default     = "10.0.1.0/24"
}

variable "availability_zone" {
    description = "Availability Zone for the Subnet"
    type        = string
    default     = "us-east-1a"
}

variable "bucket_force_destroy" {
    description = "Allow S3 bucket to be force destroyed (true for non-productions)"
    type        = bool
    default     = true
}

variable "enable_logging" {
    description = "Enable CloudFront access logging for the S3 bucket"
    type        = bool
    default     = true
}

variable "tags" {
    description = "Tags to apply to resources"
    type        = map(string)
    default     = {
        "Owner" = "SCR"
        "Project" = "Scientific-Calculator-React"
        "Environment" = "Dev"
    }
}

variable "monitor_instance_type" {
  description = "EC2 instance type for the monitor/bastion instance"
  type        = string
  default     = "t3.micro"
}

variable "monitor_key_name" {
  description = "Existing EC2 key pair name to use for SSH into monitor instance"
  type        = string
}

variable "monitor_allowed_ssh_cidr" {
  description = "CIDR allowed for SSH (e.g. your_ip/32)"
  type        = string
  default     = "0.0.0.0/0" # TODO: tighten to your IP, e.g. 1.2.3.4/32
}

variable "sns_alert_email" {
    description = "Email address for receiving CloudWatch alarm notifications"
    type = string
    default = ""
}

variable "enable_alarms" {
    description = "Whether to Enable CloudWatch alarms for the monitor instance"
    type = bool
    default = true
}
