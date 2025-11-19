data "aws_availability_zones" "available" {
  state = "available"
}

# Getting the AMI for the VM
# Using the latest ubuntu-jammy here
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  region      = var.aws_region

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
