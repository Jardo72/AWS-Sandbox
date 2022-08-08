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

data "aws_availability_zones" "available" {}

module "vpc_one" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "${var.resource_name_prefix}-VPC-#1"
  cidr                 = var.vpc_one_cidr_block
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = [cidrsubnet(var.vpc_one_cidr_block, 4, 0)]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
  tags                 = var.tags
  vpc_tags = {
    Name = "${var.resource_name_prefix}-VPC-#1"
  }
}

module "vpc_two" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "${var.resource_name_prefix}-VPC-#2"
  cidr                 = var.vpc_two_cidr_block
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = [cidrsubnet(var.vpc_two_cidr_block, 4, 0)]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
  tags                 = var.tags
  vpc_tags = {
    Name = "${var.resource_name_prefix}-VPC-#2"
  }
}

resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id      = module.vpc_one.vpc_id
  peer_vpc_id = module.vpc_two.vpc_id
  auto_accept = true
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  tags = var.tags
}

