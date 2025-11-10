variable "vpc_cidr" {
    description = "CIDR for the VPC"
    type = string
    default     = "10.0.0.0/16"
}

variable "public_subnets" {
    type = list(string)
}

variable "private_subnets" {
    type = list(string)
}

variable "region" {
    type = string
    default = "us-east-1"
}