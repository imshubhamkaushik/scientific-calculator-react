provider "aws" {
    region = var.region  
}

resource "aws_db_subnet_group" "db_subnets" {
    name = "app-db-subnet-group"
    subnet_ids = var.private_subnets  
}

resource "aws_db_instance" "postgres" {
    allocated_storage = 20
    engine = "postgres"
    engine_version = "13"
    instance_class = "db.t3.micro"
    db_name = var.db_name
    username = var.db_username
    password = var.db_password
    db_subnet_group_name = aws_db_subnet_group.db_subnets.name
    publicly_accessible = false
    skip_final_snapshot = true 
}

output "db_endpoint" {
    value = aws_db_instance.postgres.address
}