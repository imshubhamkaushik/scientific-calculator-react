variable "vpc_cidr" {
    description = "CIDR Block for the VPC"
    type        = string
}

variable "public_subnet_cidr" {
    description = "CIDR Block for the Public Subnet"
    type        = string
}

variable "availability_zone" {
    description = "Availability Zone for the Subnet"
    type        = string
}

variable "tags" {
    description = "Tags to apply to resources"
    type        = map(string)
    default     = {}
}