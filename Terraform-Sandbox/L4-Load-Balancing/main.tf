#
# Copyright 2022 Jaroslav Chmurny
#
# This file is part of AWS Sandbox.
#
# AWS Sandbox is free software developed for educational purposes. It
# is licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

terraform {
  required_version = ">=1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.15.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~>2.2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

data "aws_cloudformation_export" "deployment_artifactory_bucket_name" {
  name = "CommonDeploymentArtifactoryBucketName"
}

data "aws_cloudformation_export" "deployment_artifactory_read_access_policy_arn" {
  name = "CommonDeploymentArtifactoryReadAccessPolicyArn"
}

data "aws_route53_zone" "alias_hosted_zone" {
  name         = var.route53_alias_settings.alias_hosted_zone_name
  private_zone = false
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr_block       = var.vpc_cidr_block
  availability_zones   = var.availability_zones
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}

/* TODO:
module "nlb" {
  source               = "./modules/nlb"
  vpc_id               = module.vpc.vpc_details.id
  subnet_ids           = values(module.vpc.public_subnets)[*].subnet_id
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}

module "asg" {
  source = "./modules/asg"
}

module "route53" {
  source = "./modules/route53"
  load_balancer_dns_name = module.alb.load_balancer_details.dns_name
  load_balancer_zone_id  = module.alb.load_balancer_details.zone_id
  alias_zone_id          = data.aws_route53_zone.alias_hosted_zone.zone_id
  alias_fqdn             = var.route53_alias_settings.alias_fqdn
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
} */

/* TODO: remove
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-VPC"
  })
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-IGW"
  })
}

resource "aws_subnet" "public_subnet" {
  for_each                = var.availability_zones
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.name
  cidr_block              = each.value.public_subnet_cidr_block
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Public-Subnet-${each.key}"
  })
}

resource "aws_subnet" "private_subnet" {
  for_each                = var.availability_zones
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.name
  cidr_block              = each.value.private_subnet_cidr_block
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Private-Subnet-${each.key}"
  })
}

resource "aws_eip" "nat_gateway_elastic_ip" {
  for_each = var.availability_zones
  vpc      = true
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Elastic-IP-${each.key}"
  })
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each      = var.availability_zones
  allocation_id = aws_eip.nat_gateway_elastic_ip[each.key].id
  subnet_id     = aws_subnet.public_subnet[each.key].id
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-NAT-GW-${each.key}"
  })
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Public-Route-Table"
  })
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  for_each       = var.availability_zones
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_subnets_route_table.id
}

resource "aws_route_table" "private_subnet_route_table" {
  for_each = var.availability_zones
  vpc_id   = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway[each.key].id
  }
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Private-Route-Table-${each.key}"
  })
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  for_each       = var.availability_zones
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private_subnet_route_table[each.key].id
}

resource "aws_security_group" "ec2_security_group" {
  name        = "${local.name_prefix}-EC2-SG"
  description = "Allow inbound HTTP traffic from the ALB for the EC2 instances"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    protocol         = "tcp"
    from_port        = var.ec2_port
    to_port          = var.ec2_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-EC2-Security-Group"
  })
}

resource "aws_lb" "network_load_balancer" {
  name               = "${local.name_prefix}-ALB"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]
  tags               = local.common_tags
}

resource "aws_lb_listener" "network_load_balancer_listener" {
  load_balancer_arn = aws_lb.network_load_balancer.arn
  port              = var.nlb_port
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}

resource "aws_lb_target_group" "nlb_target_group" {
  name     = "${local.name_prefix}-NLBTargetGroup"
  vpc_id   = aws_vpc.vpc.id
  port     = var.ec2_port
  protocol = "TCP"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    // TODO: this seems to cause troubles, but it works with CloudFormation
    // interval            = 30
    // timeout             = 10 
  }
}

*/