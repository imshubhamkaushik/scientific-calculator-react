provider "aws" {
  region = "ap-south-1" # Mumbai
}

resource "aws_key_pair" "dev_key" {
  key_name   = "dev-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "web_sg" {
  name        = "react-web-sg"
  description = "Allow SSH and HTTP"
  ingress = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

resource "aws_instance" "react_server" {
  ami           = "ami-0e1d30f2c40c4c701" # Amazon Linux 2 (Mumbai)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.dev_key.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "ReactCalculator"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl enable docker
              systemctl start docker
              EOF
}
