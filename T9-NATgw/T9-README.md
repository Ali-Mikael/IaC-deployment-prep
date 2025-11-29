# Task goals
- You need to have Public Subnet and Private Subnet
- Setup NAT Gateway to Public Subnet (Route Tables for Public and Private Subnets are important)
- Create VM to Private Subnet and run app install CLI commands as user data
- Application is downloaded from Internet even if VM is in Private Subnet
- Application install must succeed
- You need to find a way to access VM in Private Subnet
- Run cli commands locally on VM in Private Submet to verify install succeeded
- Include screenshot about succesfull CLI test on VM to README.txt
- README.md contains instructions how to deploy IaC templating

# Starting point
We have no internet access for private subnets:
- <img width="1186" height="329" alt="Screenshot 2025-11-29 at 23 02 34" src="https://github.com/user-attachments/assets/9c818afd-c55e-45dd-97e8-1e7f2755dc70" />

So we simply add a NAT gateway and route all internet bound traffic from private subnets to flow through the gw.
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

# tf apply
- <img width="898" height="156" alt="Screenshot 2025-11-29 at 23 12 29" src="https://github.com/user-attachments/assets/a7067554-a4d0-4caf-ac50-47de1f98be5d" />
- <img width="191" height="35" alt="apply_complete" src="https://github.com/user-attachments/assets/496a6298-c922-47ec-af9b-aa0380b29b9f" />
- <img width="584" height="255" alt="Screenshot 2025-11-29 at 23 15 44" src="https://github.com/user-attachments/assets/c93e86f9-6e47-48a7-afc3-fe026539d64e" />     

And now we have a NAT gw and routes for it:
- <img width="1183" height="329" alt="Screenshot 2025-11-29 at 23 16 35" src="https://github.com/user-attachments/assets/c547822e-a001-40bf-b972-858dd6a2e1b5" />




