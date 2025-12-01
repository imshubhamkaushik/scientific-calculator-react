provider "aws" {
    region = var.region
}

resource "aws_launch_template" "sc_lt" {
    name_prefix = "backend-lt-"
    image_id = var.ami_id
    instance_type = var.instance_type
    key_name = var.ssh_key_name
    user_data = var.user_data
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "asg" {
    name = "backend-asg"
    desired_capacity = var.asg_desired
    max_size = 2
    min_size = 1
    vpc_zone_identifier = var.private_subnets
    launch_template {
        id = aws_launch_template.sc_lt.id
        version = "$Latest"
    }  
}

output "asg_name" {
    value = aws_autoscaling_group.asg.name  
}

# If RDS is created
output "rds_endpoint" {
    value = aws_db_instance.postgres.address  
}