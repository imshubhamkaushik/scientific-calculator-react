variable "project_name" {
    description = "Project name used for naming resources"
    type        = string
}

variable "environment" {
    description = "Deployment environment (e.g., dev, prod)"
    type        = string
}

variable "bucket_force_destroy" {
    description = "Allow S3 bucket to be force destroyed (for non-productions)"
    type        = bool
    default     = false
}

variable "enable_logging" {
    description = "Enable CloudFront access logging for the S3 bucket"
    type        = bool
    default     = true 
}

variable "cf_price_class" {
    description = "CloudFront price class"
    type        = string
    default     = "PriceClass_100"
}

variable "tags" {
    description = "Tags to apply to resources"
    type        = map(string)
    default     = {}
}