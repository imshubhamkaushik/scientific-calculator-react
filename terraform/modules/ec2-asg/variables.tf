variable "ami_id" {
    type = string
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "region" {
    type = string
    default = "us-east-1"
}

variable "ssh_key_name" {
    type = string
}

variable "asg_desired" {
    type = number
    default = 1
}

variable "private_subnets" {
    type = list(string)  
}

variable "user_data" {
    type = string
    default = ""  
}

