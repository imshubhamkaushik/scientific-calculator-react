variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "key_name" {}
variable "iam_instance_profile" {}
variable "tags" {
  type = map(string)
}
