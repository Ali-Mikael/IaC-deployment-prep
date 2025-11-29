# Provider block
# --------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Default tags
# ------------
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Course    = "Public Cloud Solution Architect"
      Project   = "IaC deployment prep tasks"
      Creator   = "Ali-G"
      ManagedBy = "Terraform"
    }
  }
}

# VPC
# ---
resource "aws_vpc" "test" {
  cidr_block = var.main_cidr

  tags = {
    Name = "test-vpc"
  }
}

# IGW
# ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "test-vpc-igw"
  }
}

# Subnet
# ------
resource "aws_subnet" "test" {
  vpc_id                  = aws_vpc.test.id
  cidr_block              = cidrsubnet(var.main_cidr, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "main-test-subnet"
  }
}

# Routing
# -------
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-subnet-rt"
  }
}
resource "aws_route_table_association" "rta" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.test.id
}

# NACL
# ----
resource "aws_network_acl" "main" {
  vpc_id     = aws_vpc.test.id
  subnet_ids = [aws_subnet.test.id]

  dynamic "ingress" {
    for_each = local.ports
    content {
      protocol   = "tcp"
      rule_no    = index(sort(keys(local.ports)), ingress.key) * 10 + 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = ingress.value
      to_port    = ingress.value
    }
  }

  # Ephemeral ports open so that we can download updates etc..
  ingress {
    protocol   = "tcp"
    rule_no    = 125
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  egress {
    protocol   = "-1"
    rule_no    = 10
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = "public-facing-nacl"
  }
}

# SG
# --
resource "aws_security_group" "sg" {
  name   = "Instance SG"
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "i" {
  for_each = local.ports

  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value
  ip_protocol       = "tcp"
  to_port           = each.value
}

resource "aws_vpc_security_group_egress_rule" "e" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Compute
# -------
resource "aws_instance" "test_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.test.id
  availability_zone      = data.aws_availability_zones.available.names[0]
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name      = aws_key_pair.vm1.key_name

  tags = {
    Name = "test-vm-1"
  }
}
# Remember to configure the public key in locals.tf
resource "aws_key_pair" "vm1" {
  key_name   = var.key_name_vm1
  public_key = local.public_key
}
output "public_ip" {
  description = "Public IP of test instance"
  value       = aws_instance.test_1.public_ip
}

# -*- Uncomment the following section && run `terraform apply` 
# for custom AMI -*-
# ------------------>
# resource "aws_ami_from_instance" "custom_ami" {
#   name               = "Custom AMI"
#   source_instance_id = aws_instance.test_1.id
#   timeouts {
#     create = "10m"
#   }
# }

# output "custom_ami_id" {
#   value = aws_ami_from_instance.custom_ami.id
# }
# <---------------------------------------------


# -*- This section is for creating a VM from that custom AMI -*-
# -------------------------------------------------------------->
# resource "aws_instance" "custom_ami_vm" {
#   ami                    = aws_ami_from_instance.custom_ami.id
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.test.id
#   availability_zone      = data.aws_availability_zones.available.names[0]
#   vpc_security_group_ids = [aws_security_group.sg.id]

#   key_name               = aws_key_pair.vm1.key_name

#   tags = {
#     Name = "custom-ami-vm"
#   }
# }
# output "public_ip-cami" {
#   description = "Public IP of custom ami instance"
#   value       = aws_instance.custom_ami_vm.public_ip
# }
# <----------------------------------------------------


# -*- Uncomment for detachable EBS volume -*-
# ------------------------------------------->
# resource "aws_ebs_volume" "ebs" {
#   availability_zone = data.aws_availability_zones.available.names[0]
#   size              = 40

#   tags = {
#     Name = "ebs-volume"
#   }
# }

# # Attaching the volume
# resource "aws_volume_attachment" "ebs" {
#   device_name = "/dev/sdh"
#   instance_id = aws_instance.test_1.id
#   volume_id   = aws_ebs_volume.ebs.id

#   stop_instance_before_detaching = true
# }
# <-------------------------------------