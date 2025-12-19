ami_id              = "ami-0abcdef12345"
instance_type       = "t2.micro"
key_name            = "my-keypair"
iam_instance_profile = "ec2-cloudwatch-role"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
az                  = "ap-south-1a"

tags = {
  Project = "ScientificCalculator"
  Env     = "Dev"
}
