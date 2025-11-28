# Compute
# -------
resource "aws_instance" "vm1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.s["public-1"].id
  key_name               = aws_key_pair.vm1.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = {
    Name = "VM-1"
  }
}

# Remember to configure the public key in locals.tf
resource "aws_key_pair" "vm1" {
  key_name   = var.key_name_vm1
  public_key = local.public_key
}

# -------------------------------------------------------------
# Uncomment if you want to create a custom AMI from an instance
# Just specify the instance ID you want to use!
# ---------------------------------------------->
# resource "aws_ami_from_instance" "custom_ami" {
#   name               = "Custom AMI"
#   source_instance_id = <instance id here!>
#   timeouts {
#     create = "10m"
#   }
# }