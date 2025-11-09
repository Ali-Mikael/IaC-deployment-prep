# Task goals:
- Decide resource naming convention
- Decide IP segmentation
- Virtual Network
- Public Subnet AZ1
- Public Subnet AZ2
- Private Subnet AZ1
- Private Subnet AZ2
- README.md contains instructions how to deploy IaC templating.       

### Subnets
We are creating:
- A VPC using cidr block `10.0.0.0/16`
- An Internet GW (attached to the VPC)
- A route table to route internet bound traffic from public subnets to to the IGW
  - We are also associating the route table with correct subnets.
- We are creating subnets dynamically using one resource block
- All resources created are getting default tags automatically, configured within the provider block (note that this doesn't apply to ELB/ALB created resources without explicit configuration)


### main.tf
```hcl
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


# Subnets and AZs
# ---------------

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
```

All code can be found in `/terraform` folder. From there you are able to see locals and variables etc.. used in this configuration
