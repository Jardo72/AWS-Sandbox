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

data "aws_route53_zone" "alias_hosted_zone" {
  name         = var.route53_alias_settings.alias_hosted_zone_name
  private_zone = false
}

module "ssm" {
  source               = "./modules/ssm"
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}

module "lambda" {
  source               = "./modules/lambda"
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}

module "api-gw" {
  source               = "./modules/api-gw"
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}

module "route53" {
  source               = "./modules/route53"
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}
