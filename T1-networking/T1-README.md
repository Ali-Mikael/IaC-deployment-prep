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


