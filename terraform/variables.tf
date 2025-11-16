# Region
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Main cidr block for the VPC
variable "main_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Assigning the first to available AZs to our subnets
variable "az_count" {
  type    = number
  default = 2
}

# Instance type for VM
variable "instance_type" {
  type = string
  default = "t2.micro"
}

# SSH key name
variable "key_name_vm1" {
  type = string
  description = "SSH key name"
  default = "vm1-key"
}