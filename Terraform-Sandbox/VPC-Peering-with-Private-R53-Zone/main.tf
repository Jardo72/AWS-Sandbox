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
  }
}

provider "aws" {
  alias  = "vpc_one_region"
  region = var.vpc_one_details.aws_region
}

provider "aws" {
  alias  = "vpc_two_region"
  region = var.vpc_two_details.aws_region
}

data "aws_availability_zones" "region_one_available" {
  provider = aws.vpc_one_region
}

data "aws_availability_zones" "region_two_available" {
  provider = aws.vpc_two_region
}

module "vpc_one" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.vpc_one_region
  }
  name               = "${var.resource_name_prefix}-VPC-#1"
  cidr               = var.vpc_one_details.cidr_block
  azs                = data.aws_availability_zones.region_one_available.names
  private_subnets    = [cidrsubnet(var.vpc_one_details.cidr_block, 4, 0)]
  enable_nat_gateway = false
  tags               = var.tags
  vpc_tags = {
    Name = "${var.resource_name_prefix}-VPC-#1"
  }
}

module "vpc_two" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.vpc_two_region
  }
  name               = "${var.resource_name_prefix}-VPC-#2"
  cidr               = var.vpc_two_details.cidr_block
  azs                = data.aws_availability_zones.region_two_available.names
  private_subnets    = [cidrsubnet(var.vpc_two_details.cidr_block, 4, 0)]
  enable_nat_gateway = false
  tags               = var.tags
  vpc_tags = {
    Name = "${var.resource_name_prefix}-VPC-#2"
  }
}
