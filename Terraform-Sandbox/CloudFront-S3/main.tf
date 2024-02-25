#
# Copyright 2024 Jaroslav Chmurny
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
      version = "~>5.35.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source                 = "./modules/s3"
  webcontent_bucket_name = var.webcontent_bucket_name
  resource_name_prefix   = var.resource_name_prefix
  tags                   = var.tags
}

module "cloudfront" {
  source                 = "./modules/cloudfront"
  web_bucket_domain_name = module.s3.webcontent_bucket_regional_domain_name
  acm_certificate_arn    = var.acm_certificate_arn
  resource_name_prefix   = var.resource_name_prefix
  tags                   = var.tags
  depends_on             = [module.s3]
}

module "s3_access_control" {
  source                      = "./modules/s3_access_control"
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn
  webcontent_bucket_id        = module.s3.webcontent_bucket_id
  webcontent_bucket_arn       = module.s3.webcontent_bucket_arn
  depends_on                  = [module.s3, module.cloudfront]
}
