# -*- Networking -*-
# ------------------

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

# NAT gw
resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = aws_subnet.s["public-1"].id
  allocation_id = aws_eip.nat.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "nat-gw"
  }
}

# EIP for NAT
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
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


# Route table for public subnets
# ------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-subnets-rt"
  }
}
# Associating public RT with public subnets
resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in aws_subnet.s : k => v if startswith(k, "public")
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route table for private subnets
# -------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-subnets-rt"
  }
}
# Associating private RT with private subnets
resource "aws_route_table_association" "private" {
  for_each = {
    for k, v in aws_subnet.s : k => v if startswith(k, "private")
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}