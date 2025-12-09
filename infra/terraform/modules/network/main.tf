data "aws_region" "curremt" {}

resource "aws_vpc" "sc_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(
        var.tags,
        {
            Name = "sc-vpc-main"
        }
    )
}

resource "aws_internet_gateway" "sc_igw" {
    vpc_id = aws_vpc.sc_vpc.id

    tags = merge(
        var.tags,
        {
            Name = "sc-igw-main"
        }
    )
}

resource "aws_subnet" "public_sub" {
    vpc_id            = aws_vpc.sc_vpc.id
    cidr_block        = var.public_subnet_cidr
    availability_zone = var.availability_zone

    tags = merge(
        var.tags,
        {
            Name = "sc-public-subnet"
            Tier = "public"
        }
    )
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.sc_vpc.id

    tags = merge(
        var.tags,
        {
            Name = "sc-public-rt"
        }
    )
}

resource "aws_route" "public_rt_route" {
    route_table_id         = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.sc_igw.id
}

resource "aws_route_table_association" "public_sub_association" {
    subnet_id      = aws_subnet.public_sub.id
    route_table_id = aws_route_table.public_rt.id
}