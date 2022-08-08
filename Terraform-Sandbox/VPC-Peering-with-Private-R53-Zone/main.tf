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

module "vpc" {
  source               = "./modules/vpc"
  vpc_one_cidr_block   = var.vpc_one_cidr_block
  vpc_two_cidr_block   = var.vpc_two_cidr_block
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}

module "ec2" {
  source               = "./modules/ec2"
  vpc_one_vpc_id       = module.vpc.vpc_one_vpc_id
  vpc_two_vpc_id       = module.vpc.vpc_two_vpc_id
  ec2_instance_type    = var.ec2_instance_type
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
  depends_on           = [module.vpc]
}

module "route53" {
  source                      = "./modules/route53"
  hosted_zone_name            = "example.jch"
  ttl                         = 300
  vpc_one_vpc_id              = module.vpc.vpc_one_vpc_id
  vpc_two_vpc_id              = module.vpc.vpc_two_vpc_id
  ec2_instance_one_ip_address = module.ec2.ec2_instance_one_ip_address
  ec2_instance_two_ip_address = module.ec2.ec2_instance_two_ip_address
  resource_name_prefix        = var.resource_name_prefix
  tags                        = var.tags
  depends_on                  = [module.ec2]
}
