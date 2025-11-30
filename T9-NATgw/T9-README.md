# Task goals
- You need to have Public Subnet and Private Subnet
- Setup NAT Gateway to Public Subnet (Route Tables for Public and Private Subnets are important)
- Create VM to Private Subnet and run app install CLI commands as user data
- Application is downloaded from Internet even if VM is in Private Subnet
- Application install must succeed
- You need to find a way to access VM in Private Subnet
- Run cli commands locally on VM in Private Subnet to verify install succeeded
- Include screenshot about succesfull CLI test on VM to README.txt
- README.md contains instructions how to deploy IaC templating

# Starting point
We have no internet access for private subnets:
- <img width="1186" height="329" alt="Screenshot 2025-11-29 at 23 02 34" src="https://github.com/user-attachments/assets/9c818afd-c55e-45dd-97e8-1e7f2755dc70" />

# NAT
**So we simply add a NAT gateway**
```hcl
# NAT gw
resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = aws_subnet.s["public-1"].id
  allocation_id = aws_eip.nat.id # <-- The EIP is a must for a public facing NAT.
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "nat-gw"
  }
}
```
**... and route all internet bound traffic from private subnets, to flow through the GW!**
```hcl
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
```

## terraform apply
- <img width="898" height="156" alt="Screenshot 2025-11-29 at 23 12 29" src="https://github.com/user-attachments/assets/a7067554-a4d0-4caf-ac50-47de1f98be5d" />
- <img width="191" height="35" alt="apply_complete" src="https://github.com/user-attachments/assets/496a6298-c922-47ec-af9b-aa0380b29b9f" />
- <img width="584" height="255" alt="Screenshot 2025-11-29 at 23 15 44" src="https://github.com/user-attachments/assets/c93e86f9-6e47-48a7-afc3-fe026539d64e" />     

## And now we have a NAT gw and routes for it:
- <img width="1183" height="329" alt="Screenshot 2025-11-29 at 23 16 35" src="https://github.com/user-attachments/assets/c547822e-a001-40bf-b972-858dd6a2e1b5" />


# Private VM and bastion host
To get a VM in a private subnet. We only need to change one line in our VM1 config.    

**The line:**
```hcl
subnet_id = aws_subnet.s["public-1"].id
```
**To =>**
```
subnet_id = aws_subnet.s["private-2"].id
```    

Thans to the NAT-gw, the VM will be able to access the internet, but how do **we** access the VM?     
By using a ***Bastion Host***:
```hcl
# Bastion host
resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.s["public-1"].id
  key_name               = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [aws_security_group.ssh_access.id] # <-- Notice this line!

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_key_pair" "bastion" {
  key_name   = var.key_name_bastion
  public_key = local.bastion_key

  tags = {
    Name = "bastion-pub-key"
  }
}
```
<img width="697" height="187" alt="Screenshot 2025-11-30 at 17 05 38" src="https://github.com/user-attachments/assets/189c2ea2-0cdf-4fcb-acb6-2f14f888f6d5" />     

We specify a new key for the bastion host, and use *agent forwarding* when we want to access the VM1.      
Note also the highlighted line in the code snippet. We are *only allowing SSH* in bastion hosts SG. Following the principle of least privilege!

## terraform apply
(I'm doing this in stages to highlight some things)
- <img width="968" height="222" alt="Screenshot 2025-11-30 at 17 16 55" src="https://github.com/user-attachments/assets/044ab94a-1b1c-4301-bb9b-4158b950ad3b" />
- Notice how the VM1 public ip is empty now, that's because we moved it to a private subnet.
- A simple output modification will do the trick!
  - <img width="536" height="271" alt="Screenshot 2025-11-30 at 17 27 48" src="https://github.com/user-attachments/assets/7851e246-ab94-4461-8a7a-bfb58d25291e" />
- Then apply again:
  - <img width="439" height="152" alt="Screenshot 2025-11-30 at 17 28 27" src="https://github.com/user-attachments/assets/1fdb0310-e6dd-4657-8324-eec776c4b04f" />
- Terraform deleted the old VM, in order to create it in the private subnet, that's why you see to VM-1s in the console:
  - <img width="677" height="247" alt="Screenshot 2025-11-30 at 17 23 46" src="https://github.com/user-attachments/assets/5a712c49-ab94-46e0-89c5-772fa27663cd" />
  - <img width="499" height="431" alt="Screenshot 2025-11-30 at 17 25 01" src="https://github.com/user-attachments/assets/0facd796-ee67-4fe6-8934-8ac259424af2" />
  - **Bastion host:**
  - <img width="224" height="65" alt="Screenshot 2025-11-30 at 17 43 16" src="https://github.com/user-attachments/assets/3869c1f3-81b6-49b6-b23e-d3e766e97200" />     

## Accessing VM1
First we add the VM1 private key to our ssh-agent, (this is good because: we don't have to store it on the bastion-host itself).
```bash
ssh-add -K ~/.ssh/vm1
```
<img width="953" height="30" alt="Screenshot 2025-11-30 at 17 30 13" src="https://github.com/user-attachments/assets/10a70eaf-559b-4d0b-9d46-7cc675937143" />     

Now when we ssh into the bastion host, we use the -A flag to enable the forwarding.
```bash
ssh -A -i ~/.ssh/bastion_key ubuntu@<bh-pub-ip>
```
<img width="1019" height="53" alt="Screenshot 2025-11-30 at 17 31 27" src="https://github.com/user-attachments/assets/63e5a6eb-253c-4d7c-915f-89ce0c0d2397" />     

Once inside the bastion-host, we copy the private address from the tf output, and ssh into VM1.
```
ssh ubntu@<vm1-priv-ip>
```
<img width="574" height="24" alt="Screenshot 2025-11-30 at 17 32 38" src="https://github.com/user-attachments/assets/99da5135-5b96-43d3-b789-e5f08c1941dc" />     

Once inside, we can update the system and download a package. (you can also notice from the output, that the provision script is still in play and works)
- <img width="1008" height="250" alt="Screenshot 2025-11-30 at 17 33 44" src="https://github.com/user-attachments/assets/a5e9d92b-7121-47ab-8838-9daeaf47d5d0" />
- <img width="1125" height="147" alt="Screenshot 2025-11-30 at 17 35 04" src="https://github.com/user-attachments/assets/5d82c5d9-9f74-4e59-97b9-bc805c26ec1b" />
- <img width="1123" height="342" alt="Screenshot 2025-11-30 at 17 35 19" src="https://github.com/user-attachments/assets/f1d1f85a-6504-4b4d-84cf-0bea1fa6f5e6" />
- <img width="952" height="627" alt="Screenshot 2025-11-30 at 17 36 00" src="https://github.com/user-attachments/assets/4a4db0a8-edbb-43bf-ba9f-958ea314f30e" />
- <img width="993" height="320" alt="Screenshot 2025-11-30 at 17 36 40" src="https://github.com/user-attachments/assets/01620fe5-2c6e-4a4b-ac18-280c3b026b75" />




# Deploying
You can either copy the `*.tf` files in this folder to your machine of choice, navigate into the folder, and initialise terraform from there:
```bash
$ terraform init
```
And then apply (to create resources):
```bash
$ terraform apply
```
This will effectively **only** create resources that are *specified in this folder*.       

## OR
You can **download** the main `/terraform` **folder** to your computer **locally** **-->** **navigate to the folder** **-->** and **execute the same steps:** to provision the whole infra in one go! 
