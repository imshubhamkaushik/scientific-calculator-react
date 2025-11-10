terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
}

provider "aws" {
    region = "us-east-1"  
}

variable "aws_region" {
    type    = string
    default = "us-east-1"
}

variable "frontend_bucket_name" {
    type = string  
}

variable "public_subnets" {
    type = list(string)
    default = ["10.0.1.0/24"]  
}

variable "private_subnets" {
    type = list(string)
    default = ["10.0.2.0/24"]  
}

variable "ssh_key_name" {
    type = string  
}

module "vpc" {
    source = "../../modules/vpc"
    vpc_cidr = "10.0.0.0/16"
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
}

module "frontend" {
    source = "../../modules/s3-cloudfront"
    bucket_name = var.frontend_bucket_name
    region = var.aws_region  
}

module "iam" {
    source = "../../modules/iam"
    s3_bucket = var.frontend_bucket_name  
}

output "bucket_name" {
    value = module.frontend.bucket_name  
}

output "cdn_domain" {
    value = module.frontend.cdn_domain  
}