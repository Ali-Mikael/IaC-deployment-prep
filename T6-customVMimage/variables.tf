variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Main cidr block for the VPC
variable "main_cidr" {
  type    = string
  default = "10.0.0.0/16"
}