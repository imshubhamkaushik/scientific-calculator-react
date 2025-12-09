module "network" {
    source = "../../modules/network"

    vpc_cidr = var.vpc_cidr
    public_subnet_cidr = var.public_subnet_cidr
    availability_zone = var.availability_zone

    tags = merge(
        var.tags,
        {
            Component = "network"
        }
    )
}

module "s3_cloudfront" {
    source = "../../modules/s3_cloudfront"

    project_name = var.project_name
    environment = var.environment
    bucket_force_destroy = var.bucket_force_destroy
    enable_logging = var.enable_logging

    tags = merge(
        var.tags,
        {
            Component = "s3-cloudfront"
        }
    )
}

module "ec2_monitor" {
    source = "../../modules/ec2_monitor"

    project_name = var.project_name
    environment = var.environment
    vpc_id = module.network.vpc_id
    subnet_id = module.network.public_subnet_id
    instance_type = var.monitor_instance_type
    key_name = var.monitor_key_name
    allowed_ssh_cidr = var.monitor_allowed_ssh_cidr
  
}

module "cloudwatch" {
    source = "../../modules/cloudwatch"

    project_name = var.project_name
    environment = var.environment
    monitor_instance_id = module.ec2_monitor.instance_id
    sns_alert_email = var.sns_alert_email
    enable_alarms = var.enable_alarms

    tags = merge(
        var.tags,
        {
            Component = "monitoring"
        }
    )
}