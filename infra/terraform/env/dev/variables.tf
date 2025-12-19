variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "iam_instance_profile" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "az" {}
variable "tags" {
  type = map(string)
}
