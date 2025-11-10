variable "db_name" {
    type = string
    default = "appdb"  
}

variable "db_username" {
    type = string
    default = "appuser"  
}

variable "db_password" {
    type = string  
}

variable "private_subnets" {
    type = list(string)  
}

variable "region" {
    type = string
    default = "us-east-1"  
}