aws_region = "us-east-1"
project_name = "scientific-calculator"
environment = "dev"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
availability_zone = "us-east-1a"
bucket_force_destroy = true
enable_logging = true

tags = {
    Owner = "SCR"
    Project = scientific-calculator-react
    Environment = "dev"
}

monitor_instance_type   = "t3.micro"
monitor_key_name        = "your-existing-keypair-name"   # TODO: change
monitor_allowed_ssh_cidr = "YOUR.IP.ADDR.HERE/32"        # e.g. "49.37.x.x/32"
sns_alert_email = "your email" # TODO
enable_alarms = true