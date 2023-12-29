# Initialise the Terraform configuration with the AWS provider
# We will be using the AWS provider to create our infrastructure on AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}



# Uncomment the following lines to create an EC2 instance with a security group, default VPC and default subnet
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
    Project = "Terraform Workshop"
  }
}
resource "aws_security_group" "demo" {
  name        = "EC2 Demo Security Group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_default_vpc.default.id
  tags = {
    Name = "EC2 Demo Security Group"
    Project = "Terraform Workshop"
  }

}
resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.demo.id
}


resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.demo.id
}

resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.demo.id
}

resource "aws_instance" "demo_instance" {
  ami                         = "ami-0905a3c97561e0b69"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.demo.name]
  user_data                   = <<-EOF
               #!/bin/bash
               # enables ssh password authentication
               sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
               sudo service sshd restart
               # changes ubuntu user password to hellovodafone
               echo "ubuntu:hellovodafone" | sudo chpasswd
               # install nginx
               sudo apt-get update
               sudo apt-get install -y nginx
               # start nginx
               sudo service nginx start
               # Update index.html
               echo "<h1>Welcome to Terraform Workshop</h1>" | sudo tee /var/www/html/index.html
               # restart nginx
               sudo service nginx restart
               EOF
  tags = {
    Name = "EC2 Demo Instance"
    Project = "Terraform Workshop"
  }
}

output "ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.demo_instance.public_ip
}
