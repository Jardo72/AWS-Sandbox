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

module "nlb" {
  source     = "./modules/nlb"
  vpc_id     = module.vpc.vpc_details.id
  subnet_ids = values(module.vpc.public_subnets)[*].subnet_id
  target_ec2_settings = {
    port = var.ec2_settings.port
  }
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
  depends_on           = [module.vpc]
}

module "asg" {
  source           = "./modules/asg"
  vpc_id           = module.vpc.vpc_details.id
  vpc_cidr_block   = var.vpc_cidr_block
  subnet_ids       = values(module.vpc.private_subnets)[*].subnet_id
  target_group_arn = module.nlb.target_group_details.arn
  application_installation = {
    deployment_artifactory_bucket_name     = data.aws_cloudformation_export.deployment_artifactory_bucket_name.value
    deployment_artifactory_prefix          = var.application_installation.deployment_artifactory_prefix
    application_jar_file                   = var.application_installation.application_jar_file
    deployment_artifactory_access_role_arn = data.aws_cloudformation_export.deployment_artifactory_read_access_policy_arn.value
  }
  ec2_instance = {
    instance_type = var.ec2_settings.instance_type
    port          = var.ec2_settings.port
  }
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
  depends_on           = [module.vpc, module.nlb]
}

module "route53" {
  source                 = "./modules/route53"
  load_balancer_dns_name = module.nlb.load_balancer_details.dns_name
  load_balancer_zone_id  = module.nlb.load_balancer_details.zone_id
  alias_zone_id          = data.aws_route53_zone.alias_hosted_zone.zone_id
  alias_fqdn             = var.route53_alias_settings.alias_fqdn
  depends_on             = [module.nlb]
}

module "cloudwatch" {
  source                 = "./modules/cloudwatch"
  aws_region             = var.aws_region
  dashboard_name         = "TODO"
  autoscaling_group_name = module.asg.autoscaling_group_details.name
  load_balancer_arn      = module.nlb.load_balancer_details.arn
  target_group_arn       = module.nlb.target_group_details.arn
  depends_on             = [module.nlb, module.asg]
}
