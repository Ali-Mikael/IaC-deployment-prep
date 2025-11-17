locals {
  # The file/path/to/your/public_key on your local machine
  public_key = file("~/.ssh/bastion_key.pub")

  # Port numbers
  ports = {
    ssh   = 22
    http  = 80
    https = 443
  }
}
