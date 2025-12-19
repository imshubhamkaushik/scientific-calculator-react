variable "cidr_block" {}
variable "public_subnet_cidr" {}
variable "availability_zone" {}
variable "tags" {
  type = map(string)
}
