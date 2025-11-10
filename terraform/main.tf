terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Default tags to be applied to all created resources
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


# ----------
# Networking
# ----------

# VPC
resource "aws_vpc" "main" {
  cidr_block       = var.main_cidr
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# The Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-vpc-igw"
  }
}

# Subnets 
# -------
resource "random_shuffle" "az" {
  input        = data.aws_availability_zones.available.names
  result_count = var.az_count
  seed         = var.aws_region
}

resource "aws_subnet" "s" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = element(random_shuffle.az.result, index(keys(local.subnets), each.key))
  map_public_ip_on_launch = startswith(each.key, "public")

  tags = {
    Name = "subnet-${each.key}"
  }
}


# Routing
# -------

# Creating a route table for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-subnets-rt"
  }
}

# Associating public route table with public subnets
# If clause makes sure only public subnets get associated
resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in aws_subnet.s : k => v
    if startswith(k, "public")
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}


# ----------------------------
# Network Access Control Lists
# ----------------------------
resource "aws_network_acl" "nacl" {
  # Creating NACL dynamically based on local.nacl values
  for_each = local.nacl
  vpc_id   = aws_vpc.main.id

  # Attaching ACLs to subnets dynamically
  subnet_ids = [
    for k, subnet in aws_subnet.s : subnet.id if(
      each.key == "public" && length(regexall("public", k)) > 0 ||
      each.key == "private" && length(regexall("private", k)) > 0
    )
  ]

  # Public NACL rules
  dynamic "ingress" {
    for_each = each.key == "public" ? local.ports : {}
    iterator = rule
    content {
      protocol   = "tcp"
      rule_no    = index(local.rule_count, rule.key) * 10 + 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = rule.value
      to_port    = rule.value
    }
  }

  # Private NACL rules
  dynamic "ingress" {
    for_each = each.key == "private" ? local.private_ingress_rules : []
    iterator = rule
    content {
      protocol   = "tcp"
      rule_no    = index(local.private_ingress_rules, rule.value) * 10 + 100
      action     = "allow"
      cidr_block = rule.value.cidr
      from_port  = rule.value.port
      to_port    = rule.value.port
    }

  }

  # Egress rule for all NACLs, accepting all outgoing by default
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = each.value
  }
}

# Security groups
# ---------------

resource "aws_security_group" "allow_ssh" {
  name   = "allow ssh"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"

  from_port   = local.ports.ssh
  to_port     = local.ports.ssh
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # equivalent to all ports
}


# -------
# Compute
# -------
resource "aws_instance" "vm1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.s["public-1"].id
  key_name               = aws_key_pair.vm1.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "VM-1"
  }
}

# Remember to configure the public key in locals.tf
resource "aws_key_pair" "vm1" {
  key_name   = var.key_name_vm1
  public_key = local.public_key
}


# -------
# Storage
# -------


# Bucket creation
resource "aws_s3_bucket" "b" {
  for_each = local.buckets

  bucket = each.value

  tags = {
    Name = "${each.key}-bucket"
  }
}

# Versioning buckets
resource "aws_s3_bucket_versioning" "v" {
  for_each = aws_s3_bucket.b
  bucket   = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle config for buckets
resource "aws_s3_bucket_lifecycle_configuration" "lc" {
  for_each = { for k, v in aws_s3_bucket.b : k => v if k == "private" }
  bucket   = each.value.id

  rule {
    id     = "cleanup-noncurrent"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}



# Effectively making the public bucket -> Public
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.b["public"].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}



# resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
#   for_each = aws_s3_bucket.b
#   bucket   = each.value.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
