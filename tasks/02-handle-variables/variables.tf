variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_ami" {
  type    = string
  default = "ami-0905a3c97561e0b69"
}

variable "instance_ssh_password" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "enable_public_ip" {
  type    = bool
  default = true
}
