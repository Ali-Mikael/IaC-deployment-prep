locals {
  # Splitting the main CIDR (/16) into /24 subnets
  subnets = {
    public-1  = cidrsubnet(var.main_cidr, 8, 1)
    public-2  = cidrsubnet(var.main_cidr, 8, 2)
    private-1 = cidrsubnet(var.main_cidr, 8, 3)
    private-2 = cidrsubnet(var.main_cidr, 8, 4)
  }

  # Creating list of the keys so we can iterate in our for_each in the resource block
  subnet_keys = sort(keys(local.subnets))

}

locals {
  ports = {
    ssh   = 22
    http  = 80
    https = 443
  }
  rule_count = sort(keys(local.ports))


  # Network Access Control Lists
  nacl = {
    public  = "public-nacl"
    private = "private-nacl"
  }

  # List of public cidrs we can use in our code
  public_cidrs = [for k, v in local.subnets : v if(startswith(k, "public"))]

  # This enables us accepting traffic (only) from multiple public subnets 
  private_ingress_rules = flatten([
    for k, port in local.ports : [
      for cidr in local.public_cidrs : {
        port = port
        cidr = cidr
      }
    ]
  ])
}


locals {
  # Configure the file/path/to your public key on your local machine
  public_key = file("~/.ssh/bastion_key.pub")
}