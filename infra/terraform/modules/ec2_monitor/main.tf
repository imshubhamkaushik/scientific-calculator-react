locals {
  base_name = "${var.project_name}-${var.environment}-monitor"
}

data "aws_ami" "amazon_linux_2" {
    most_recent = true

    filter {
      name = "owner-alias"
      values = [ "amazon" ]
    }

    owners = [ "137112412989" ] # Amazon
}

# Security Group for monitor/bastion instance
resource "aws_security_group" "monitor_sg" {
    name = "${local.base_name}-sg"
    description = "Security Group for monitor/bastion instance"
    vpc_id = var.vpc_id

    ingress {
        description = "SSH access from allowed CIDR"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ var.allowed_ssh_cidr ]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags = merge(
        var.tags,
        {
            Name = "${local.base_name}-sg"
        }
    )
}

# IAM role for EC2 to talk to CloudWatch, SSM, etc
data "aws_iam_policy_document" "assume_role" {
    statement {
        actions = [ "sts:AssumeRole" ]
        principals {
            type = "Service"
            identifiers = [ "ec2.amazonaws.com" ]
        }
    }
}

# Attach AWS managed policy for SSM (nce for demo and Ansible via SSM if needed)
resource "aws_iam_role_policy_attachment" "ssm_core" {
    role = aws_iam_role.monitor_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Inline policy for CloudWatch metrics + logs
resource "aws_iam_policy_document" "cw_policy" {
    statement {
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "cloudwatch:PutMetricData",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:ListMetrics",
            "cloudwatch:PutMetricAlarm",
            "cloudwatch:DescribeAlarms"
        ]
        resources = [ "*" ]
    }
}

resource "aws_iam_role_policy" "cw_policy" {
    name = "${local.base_name}-cw-policy"
    role = aws_iam_role.monitor_role.id
    policy = data.aws_iam_policy_document.cw_policy.json
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "monitor_profile" {
    name = "${local.base_name}-instance-profile"
    role = aws_iam_role.monitor_role.name
}

# User data: basic setup so Ansible can run easily
locals {
  user_data = <<-EOF
              #!/bin/bash
              set -xe

              # Update system
              yum update -y

              # Install basic tools
              yum install -y python3 git jq curl amazon-cloudwatch-agent

              # Enable & start cloudwatch agent (config will be provided by Ansible later)
              systemctl enable amazon-cloudwatch-agent
              EOF
}

# EC2 instance
resource "aws_instance" "monitor" {
    ami = data.aws_ami.amazon_linux_2.id
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = var.subnet_id
    vpc_security_group_ids = [ aws_security_group.monitor_sg.id ]
    iam_instance_profile = aws_iam_instance_profile.monitor_profile.name
    
    user_data = local.user_data

    root_block_device {
      volume_size = var.root_volume_size
      volume_type = "gp3"
    }

    tags = merge(
        var.tags,
        {
            Name = "${local.base_name}-instance"
            Role = "monitor-bastion"
        }
    )
}