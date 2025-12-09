variable "project_name" {
    description = "Project name used for naming resources"
    type        = string
}

variable "environment" {
    description = "Deployment environment (e.g., dev, prod)"
    type        = string
}

variable "vpc_id" {
    description = "VPC ID where the EC2 instance will be deployed"
    type        = string
}

variable "subnet_id" {
    description = "Subnet ID where the EC2 instance will be deployed"
    type        = string
}

variable "instance_type" {
    description = "Instance type for the EC2 instance"
    type        = string
    default     = "t2.micro"
}

variable "key_name" {
    description = "Name of the existing EC2 key pair to use for SSH access"
    type        = string
}

variable "allowed_ssh_cidr" {
    description = "CIDR blocks allowed to SSH to the EC2 instance"
    type        = string
}

variable "root_volume_size" {
    description = "Size of the root EBS volume in GB"
    type        = number
    default     = 8  
}

variable "tags" {
    description = "Tags to apply to resources"
    type        = map(string)
    default     = {}
}