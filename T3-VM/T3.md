# Task goals
- Create Key Pair
- Create Linux VM
- Launch Linux VM to Public Subnet (requires Public IP Address)
- Tag Created Resources (Course, Implementation, Task, Student, Deployment Type)
- SSH to VM
- Read VM metadata with curl on VM and inlude screenshot to task README.txt
- README.md contains instructions how to deploy IaC templating.


## Key pair
For the you to be able to log in to your VM, you need an asymmetric key pair.      
You could use terraform for this, but it's better to create it locally, and just let terraform do the heavy lifting for you, meaning
transfer the public key to your VM.     
<br> 
Create key pair locally:
```bash
$ ssh-keygen -t ed25519 -C "<enter-your-label-here>"
```
- The string after the `-C` flag adds a label to your key, used for identification.
- When asked to save the key you can then change the name to something you'll remember, say `VM1key` for example.      

Now you can reference it in your code.      
Example from our configuration here:
```hcl
locals {
  # The file/path/to/your/public_key on your local machine
  public_key = file("~/.ssh/bastion_key.pub")
}
```
You'll soon see how it's used!      


## variables.tf
```hcl
# Compute
# -------

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "key_name_vm1" {
  type = string
  description = "SSH key name"
  default = "vm1-key"
}
```


## VM
Again, `main.tf` abbreviated for readability.       
Here is basically what we added:
```hcl
# Security groups
# ---------------

resource "aws_security_group" "allow_ssh" {
  name   = "allow ssh"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"

  from_port   = local.ports.ssh
  to_port     = local.ports.ssh
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # equivalent to all ports
}

# -------
# Compute
# -------

resource "aws_instance" "vm1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.s["public-1"].id
  key_name               = aws_key_pair.vm1.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "VM-1"
  }
}

# remember to configure the public key in locals.tf
resource "aws_key_pair" "vm1" {
  key_name   = var.key_name_vm1
  public_key = local.public_key
}
```
**What are we creating?**
- We are creating a security group for the instance, so that we can SSH into it.
- We are creating the instance, based on an AMI we got from the `data block`.
  - It checks for an official ubuntu release by **Canonical** (the owner of ubuntu).
- We are using the public key we created earlier for authorization.
  

## terraform apply
- Update you're aws credentials if you have to
  - <img width="880" height="52" alt="Screenshot 2025-11-09 at 12 39 46" src="https://github.com/user-attachments/assets/e6875a76-b1cf-4a86-a3b2-a56fb6730b21" />
- Initialize terraform, validate your configuration, and if everything looks good: `$ terraform apply`
  - <img width="877" height="533" alt="Screenshot 2025-11-09 at 12 39 26" src="https://github.com/user-attachments/assets/77ca5843-355f-4901-a62f-22db3b987ea7" />

Now we can check the console to make sure it worked:
- <img width="864" height="164" alt="Screenshot 2025-11-09 at 13 03 34" src="https://github.com/user-attachments/assets/48f57b8a-5306-403f-b035-3ea865e7f2b8" />

Because of our configuration in our `public subnet resource` creation.      
**Specifically the line:**
```hcl
map_public_ip_on_launch = startswith(each.key, "public")
```
Everytime we launch something in the public subnets, we automatically get a public IP assigned to it.      
So now we only have to check the public IP address and connect to it!      
<br> 

## Accessing the vm
For ease of use, we have an `outputs.tf` file, and the following configuration:
```hcl
output "public_ip" {
  value = aws_instance.vm1.public_ip
  description = "Public IP of bastion host"
}
```
When terraform has created your resource, it will output the address like so:
- <img width="801" height="189" alt="Screenshot 2025-11-09 at 15 42 48" src="https://github.com/user-attachments/assets/830478fb-44cd-4935-81f5-f1b744f41a82" />

We can also run `$ terraform output` to get what we want:
- <img width="762" height="47" alt="Screenshot 2025-11-09 at 15 45 20" src="https://github.com/user-attachments/assets/7d593f7a-89ba-4332-bef4-c98b1d2eb7c5" />



Then, from our command line locally:
```bash
$ ssh -i <path-to-private-key> ubuntu@<vm-pub-ip>
```
- The `-i` flag tells us which corresponding private key to use for authorization
  - Just replace *"path-to-private-key"* with your own && the *"vm-pub-ip"* with the IP address you got from the output variable.


**Result:**
- <img width="833" height="510" alt="Screenshot 2025-11-09 at 16 01 36" src="https://github.com/user-attachments/assets/10de8772-aaf1-4736-a93d-70a26e3c80e5" />
- Everything works!
  - We have succesfully created a VM and accessed it via SSH. 💯



# Deploying
You can either copy the `*.tf` files in this folder to your machine of choice, navigate into the folder, initialise terraform from there:
```
$ terraform init
```
And then apply (to create resources):
```
$ terraform apply
```
This will effectively **only** create resources that are specified in this folder.       

## OR
You can **download** the main `/terraform` **folder** to your computer **locally** **-->** **navigate to the folder** **-->** and **execute the same steps:** to provision the whole infra in one go!
