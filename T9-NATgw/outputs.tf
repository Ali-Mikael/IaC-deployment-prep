output "bastion_public_ip" {
  value = aws_instance.bastion_host.public_ip
  description = "Public IP of bastion host"
}

output "vm1_private_ip" {
  value = aws_instance.vm1.private_ip
  description = "Private IP of VM1"
}