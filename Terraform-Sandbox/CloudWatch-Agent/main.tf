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

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = "${var.resource_name_prefix}-VPC"
  cidr               = "10.0.0.0/16"
  azs                = data.aws_availability_zones.available.names
  public_subnets     = ["10.0.0.0/24"]
  private_subnets    = ["10.0.1.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = var.tags
  vpc_tags = {
    Name = "${var.resource_name_prefix}-VPC"
  }
}

module "ec2" {
  source               = "./modules/ec2"
  aws_region           = var.aws_region
  instance_type        = var.ec2_instance_type
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}

module "cloudwatch" {
  source         = "./modules/cloudwatch"
  aws_region     = var.aws_region
  dashboard_name = var.resource_name_prefix
}
