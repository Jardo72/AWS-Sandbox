provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Name          = "L7-Load-Balancing-Demo",
    ProvisionedBy = "Terraform"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = local.common_tags
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.common_tags
}

resource "aws_subnet" "public_subnet_one" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags                    = local.common_tags
}

resource "aws_subnet" "public_subnet_two" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                    = local.common_tags
}

resource "aws_subnet" "private_subnet_one" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = false
  tags                    = local.common_tags
}

resource "aws_subnet" "private_subnet_two" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = false
  tags                    = local.common_tags
}

resource "aws_eip" "nat_gateway_elastic_ip" {
  vpc  = true
  tags = local.common_tags
}

# https://dev.betterdoc.org/infrastructure/2020/02/04/setting-up-a-nat-gateway-on-aws-using-terraform.html
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_elastic_ip.id
  subnet_id     = aws_subnet.public_subnet_one.id
  tags          = local.common_tags
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = local.common_tags
}

resource "aws_route_table_association" "public_subnet_one_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_one.id
  route_table_id = aws_route_table.public_subnets_route_table.id
}

resource "aws_route_table_association" "public_subnet_two_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_two.id
  route_table_id = aws_route_table.public_subnets_route_table.id
}

resource "aws_route_table" "private_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = local.common_tags
}

resource "aws_route_table_association" "private_subnet_one_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_one.id
  route_table_id = aws_route_table.private_subnets_route_table.id
}

resource "aws_route_table_association" "private_subnet_two_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_two.id
  route_table_id = aws_route_table.private_subnets_route_table.id
}

resource "aws_security_group" "alb_security_group" {
  name        = "ALB-Security-Group"
  description = "Security group for the ALB"
  vpc_id      = aws_vpc.vpc.id
  tags = local.common_tags
}

resource "aws_security_group_rule" "alb_security_group_ingress_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_security_group.id
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow inbound HTTP from anywhere"
}

resource "aws_security_group_rule" "alb_security_group_egress_rule" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb_security_group.id
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.ec2_security_group.id
  description              = "Allow outbound traffic to the EC2 instances"
}

resource "aws_security_group" "ec2_security_group" {
  name        = "EC2-Security-Group"
  description = "Allow inbound HTTP traffic from the ALB for the EC2 instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb_security_group.id]
    description     = "Allow inbound HTTP"
  }
}
