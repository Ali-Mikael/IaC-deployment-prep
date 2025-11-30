# Network Access Control Lists
# ----------------------------
resource "aws_network_acl" "nacl" {
  # Creating NACL dynamically based on local.nacl values
  for_each = local.nacl
  vpc_id   = aws_vpc.main.id

  # Attaching ACLs to subnets dynamically
  subnet_ids = [
    for k, subnet in aws_subnet.s : subnet.id if(
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
  # Ephemeral ports open so that we can download updates etc..
  ingress {
    protocol   = "tcp"
    rule_no    = 125
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Accepting all outgoing
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = each.value
  }
}


# Security groups
# ---------------

# EC2 instance security group
resource "aws_security_group" "instance_sg" {
  name   = "SG for Instance"
  vpc_id = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "instance-security-group"
  }
}
# Ingress rules + attach to SG
resource "aws_vpc_security_group_ingress_rule" "instance_sg" {
  for_each          = local.ports
  security_group_id = aws_security_group.instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"


  from_port   = each.value
  to_port     = each.value
  ip_protocol = "tcp"
}
# Egress rule + attach to SG
resource "aws_vpc_security_group_egress_rule" "instance_sg" {
  security_group_id = aws_security_group.instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # equivalent to all ports
}

resource "aws_security_group" "ssh_access" {
  name   = "Admin SSH access"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = local.ports.ssh
    to_port     = local.ports.ssh
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "admin-SSH-access"
  }
}