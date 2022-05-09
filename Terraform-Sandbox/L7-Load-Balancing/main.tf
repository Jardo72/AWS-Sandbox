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
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = local.common_tags
}

/*
resource "aws_subnet" "public_subnet_one" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.vpc.id
  tags = common_tags
}

resource "aws_subnet" "public_subnet_two" {
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.0.1/24"
  vpc_id = aws_vpc.vpc.id
  tags = common_tags
} */

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.common_tags
}

resource "aws_eip" "nat_gateway_elastic_ip" {
  vpc  = true
  tags = local.common_tags
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = local.common_tags
}

/*
https://dev.betterdoc.org/infrastructure/2020/02/04/setting-up-a-nat-gateway-on-aws-using-terraform.html
resource "aws_nat_gateway" "nat_gateway" {

  tags = local.common_tags
} */
