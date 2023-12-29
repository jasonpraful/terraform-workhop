output "instance_ip" {
  value       = aws_eip.demo.public_ip
  description = "EC2 instance public IP"
}
