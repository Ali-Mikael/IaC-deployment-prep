locals {

    # Splitting the main CIDR (/16) into /24 subnets
    subnets = {
       public-1 = cidrsubnet(var.main_cidr, 8, 1)
       public-2 = cidrsubnet(var.main_cidr, 8, 2)
       private-1 = cidrsubnet(var.main_cidr, 8, 3)
       private-2 = cidrsubnet(var.main_cidr, 8, 4)
    }

    subnet_keys = sort(keys(local.subnets))



}