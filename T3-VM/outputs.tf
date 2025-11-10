output "public_ip" {
  value = aws_instance.vm1.public_ip
  description = "Public IP of bastion host"
}