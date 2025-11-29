# Compute
# -------
resource "aws_instance" "vm1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.s["public-1"].id
  key_name               = aws_key_pair.vm1.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  user_data              = file("./files/init-script.sh")
  # If user_data changes, tf will create a new VM and destroy old one
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true

    tags = {
      Name   = "vm1-root-volume"
      Backup = "Daily"
    }

  }
  tags = {
    Name = "VM-1"
  }
}

# Remember to configure the public key in locals.tf
resource "aws_key_pair" "vm1" {
  key_name   = var.key_name_vm1
  public_key = local.public_key
}


# -*- Uncomment if you want to create a custom AMI from an instance
# Just specify the instance ID you want to use! -*- 
# ------------------------------------------------>
# resource "aws_ami_from_instance" "custom_ami" {
#   name               = "Custom AMI"
#   source_instance_id = aws_instance.vm1.id
#   timeouts {
#     create = "10m"
#   }
# }

# -*- Uncomment to create VM from that AMI -*-
# ------------------------------------------->
# resource "aws_instance" "custom_vm" {
#   ami                         = aws_ami_from_instance.custom_ami.id
#   instance_type               = var.instance_type
#   subnet_id                   = aws_subnet.s["public-1"].id
#   key_name                    = aws_key_pair.vm1.key_name
#   vpc_security_group_ids      = [aws_security_group.instance_sg.id]

#   tags = {
#     Name = "customVM"
#   }
# }
# output "customVM_public_ip" {
#   value = aws_instance.custom_vm.public_ip
#   description = "Public IP of custom VM"
# }
# <----------------------------------------