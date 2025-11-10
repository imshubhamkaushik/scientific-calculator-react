provider "aws" {
    region = var.region
}

resource "aws_vpc" "sc_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = { Name = "sc_vpc" }  
}

resource "aws_subnet" "public" {
    for_each = toset(var.public_subnets)
    vpc_id = aws_vpc.sc_vpc.id
    cidr_block = each.value
    map_public_ip_on_launch = true
    tags = { Name = "sc_public-${each.value}" }
}

resource "aws_subnet" "private" {
    for_each = toset(var.private_subnets)
    vpc_id = aws_vpc.sc_vpc.id
    cidr_block = each.value
    map_public_ip_on_launch = false
    tags = { Name = "sc_private-${each.value}" }
}

resource "aws_internet_gateway" "sc_igw" {
    vpc_id = aws_vpc.sc_vpc.id
    tags = { Name = "sc_igw" }
}

resource "aws_route_table" "sc_public_rt" {
    vpc_id = aws_vpc.sc_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.sc_igw.id
    }
    tags = { Name = "sc_public_rt" }
}

resource "aws_route_table_association" "sc_public_rt_association" {
    for_each = aws_subnet.public
    subnet_id = each.value.id
    route_table_id = aws_route_table.sc_public_rt.id
}

output "vpc_id" { value = aws_vpc.sc_vpc.id }
output "public_subnet_ids" { value = [for s in aws_subnet.public: s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private: s.id] }