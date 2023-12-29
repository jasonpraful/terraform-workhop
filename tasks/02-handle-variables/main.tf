
resource "aws_default_vpc" "default" {
  tags = {
    Name    = "Default VPC"
    Project = local.project_name
  }
}

resource "aws_security_group" "demo" {
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_default_vpc.default.id
  tags = {
    Name    = "EC2 Demo Security Group"
    Project = local.project_name
  }
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = local.default_protocol
  cidr_blocks       = local.default_cidr_blocks
  security_group_id = aws_security_group.demo.id
}

resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = local.default_protocol
  cidr_blocks       = local.default_cidr_blocks
  security_group_id = aws_security_group.demo.id
}

resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = local.default_cidr_blocks
  security_group_id = aws_security_group.demo.id
}

resource "aws_instance" "demo_instance" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  associate_public_ip_address = var.enable_public_ip
  security_groups             = [aws_security_group.demo.name]
  user_data                   = <<-EOF
               #!/bin/bash
               # enables ssh password authentication
               sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
               sudo service sshd restart
               # changes ubuntu user password to var.instance_ssh_password
               echo "ubuntu:${var.instance_ssh_password}" | sudo chpasswd
               # install nginx
               sudo apt-get update
               sudo apt-get install -y nginx
               # start nginx
               sudo service nginx start
               # Update index.html
               echo "<h1>Welcome to Terraform Workshop</h1><br/><p>running on $(hostname -f)<br/>Run By: ${data.aws_ssm_parameter.email.value}</p>" | sudo tee /var/www/html/index.html
               # restart nginx
               sudo service nginx restart
               EOF
  tags = {
    Name    = "EC2 Demo Instance"
    Project = local.project_name
  }
}

# create elastic ip
resource "aws_eip" "demo" {
  depends_on = [aws_instance.demo_instance]
  instance   = aws_instance.demo_instance.id
  tags = {
    Name    = "EC2 Demo Elastic IP"
    Project = local.project_name
  }
}
