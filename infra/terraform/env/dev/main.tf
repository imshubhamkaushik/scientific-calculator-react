module "vpc" {
  source                = "../../modules/vpc"
  cidr_block             = var.vpc_cidr
  public_subnet_cidr     = var.public_subnet_cidr
  availability_zone      = var.az
  tags                   = var.tags
}

module "sg" {
  source = "../../modules/security-group"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source                = "../../modules/ec2"
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  subnet_id             = module.vpc.public_subnet_id
  security_group_id     = module.sg.sg_id
  key_name              = module.iam_cloudwatch.instance_profile_name
  iam_instance_profile  = var.iam_instance_profile
  tags                  = var.tags
}

module "iam_cloudwatch" {
  source = "../../modules/iam-cloudwatch"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    InstanceId = module.ec2.instance_id
  }
}