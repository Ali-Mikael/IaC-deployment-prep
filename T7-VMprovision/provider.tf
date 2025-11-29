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