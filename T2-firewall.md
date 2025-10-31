# Task goals:
- Public Subnet firewall: allow 22, 80, 443 from the Internet
- Private Subnet firewall: allow 22, 80, 443 from Public Subnet
- **README.md contains instructions how to deploy IaC templating.**            

## Security
Expanding on our previous configurations, we are now creating **NACLs** for our subnets.     
**Challenge:**
- The task was challenging for me, because I wanted create the NACLs + rules in one resource.
- I had to find a way to create the private rules with the following limitation:
  - **Private** subnets accept traffic *only* from > **Public** subnets.
- In general this was a nice little challenge and I enjoyed it thorougly while learning **a bunch of new stuff!**         

**So, what did we come up with?**          
Let's expand the configurations a little bit. >>>                 

### locals.tf
```hcl
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
```

We now have values we can use in resource creation!     
**Shortly:** We solved the challenge by creating a `flattened list of objects` for the private ingress rules. This maps each rule to each (public) subnet (to allow traffic from), and next you'll see it in action.       

### main.tf
(previous configurations redacted for brevity/readability)
```hcl
# ----------------------------
# Network Access Control Lists
# ----------------------------
resource "aws_network_acl" "nacl" {
  # Creating NACL dynamically based on local.nacl values
  for_each = local.nacl
  vpc_id   = aws_vpc.main.id

  # Attaching ACLs to subnets dynamically
  subnet_ids = [
    for k, subnet in aws_subnet.s : subnet.id if (
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

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.main_cidr
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = each.value
  }
}
```

### Basically
The first for_each section creates NACLs based on our local values (so 2 in total):
```hcl
 # Network Access Control Lists
  nacl = {
    public  = "public-nacl"
    private = "private-nacl"
  }
```
We then use two inline `dynamic blocks` to generate ingress rules for NACLs. The conditional logic we have in place ensures each rule gets correctly appointed to its corresponding list.     
Like this:
```hcl
for_each = each.key == "private" ? local.private_ingress_rules : []
```
The `each.key == "private" ?` checks the outer loop (the NACL creation). If the key is private, it will derive values from the `private_ingress_rules`.     
<br> 
**Q:** Why use two dynamic ingress blocks?       
**A:** Because the public rules can derive their values straight from local.ports, as they have to be created **only 1 time!**       
It would get too complex to create everything in the same block. Plus this way its easier to move around and change private/public rules!      
<br> 


### Run it
- <img width="882" height="533" alt="Screenshot 2025-10-31 at 16 25 34" src="https://github.com/user-attachments/assets/b5879341-0f9b-4c99-8d68-1a64fdc89bbe" />
- <img width="664" height="96" alt="Screenshot 2025-10-31 at 16 24 12" src="https://github.com/user-attachments/assets/5b0c9862-7a96-4153-ac53-e31e7cc1a6b9" />
**VPC & subnets**
- <img width="845" height="432" alt="Screenshot 2025-10-31 at 16 26 43" src="https://github.com/user-attachments/assets/993882ba-9789-4236-9364-a12ebaa44ec6" />
**Private NACL and associations:**
- <img width="1650" height="643" alt="Screenshot 2025-10-31 at 16 27 51" src="https://github.com/user-attachments/assets/fe0c7abc-eb16-43cc-ae3e-103677546938" />
- <img width="1231" height="452" alt="Screenshot 2025-10-31 at 16 33 58" src="https://github.com/user-attachments/assets/12e56957-056b-4403-8d00-3796cfd66409" />
**Public NACL and associations:**
- <img width="1632" height="540" alt="Screenshot 2025-10-31 at 16 34 16" src="https://github.com/user-attachments/assets/84ac5f05-e0a0-4506-a551-4cdc40ec9ab4" />
- <img width="1385" height="452" alt="Screenshot 2025-10-31 at 16 34 37" src="https://github.com/user-attachments/assets/76cc216e-7757-46b2-b25d-e896ba68aee4" />




