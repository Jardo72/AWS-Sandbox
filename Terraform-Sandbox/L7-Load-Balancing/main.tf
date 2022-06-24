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

data "aws_cloudformation_export" "deployment_artifactory_bucket_name" {
  name = var.application_installation.deployment_artifactory_bucket_name_export
}

data "aws_cloudformation_export" "deployment_artifactory_read_access_policy_arn" {
  name = var.application_installation.deployment_artifactory_access_role_arn_export
}

data "aws_cloudformation_export" "common_elb_access_log_bucket_name" {
  name = var.alb_access_log_settings.bucket_name_export
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

module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.vpc.vpc_details.id
  vpc_cidr_block = module.vpc.vpc_details.cidr_block
  subnet_ids     = values(module.vpc.subnets)[*].subnet_id
  alb_listener_settings = {
    port     = var.alb_port
    protocol = "HTTP"
  }
  alb_access_log_settings = {
    bucket_name = data.aws_cloudformation_export.common_elb_access_log_bucket_name.value
    prefix      = var.alb_access_log_settings.prefix
    enabled     = var.alb_access_log_settings.enabled
  }
  target_ec2_settings = {
    port                  = var.ec2_settings.port
    protocol              = "HTTP"
    healthy_threshold     = 3
    unhealthy_threshold   = 3
    health_check_interval = 20
    health_check_timeout  = 10
    health_check_path     = "/api/health-check"
    health_check_matcher  = "200"
  }
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}

module "asg" {
  source                          = "./modules/asg"
  vpc_id                          = module.vpc.vpc_details.id
  subnet_ids                      = values(module.vpc.subnets)[*].subnet_id
  target_group_arn                = module.alb.target_group_details.arn
  load_balancer_security_group_id = module.alb.load_balancer_details.security_group_id
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
  autoscaling_group = {
    min_size                         = var.autoscaling_group_settings.min_size
    max_size                         = var.autoscaling_group_settings.max_size
    desired_capacity                 = var.autoscaling_group_settings.desired_capacity
    target_cpu_utilization_threshold = var.autoscaling_group_settings.target_cpu_utilization_threshold
  }
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}

module "route53" {
  source                 = "./modules/route53"
  load_balancer_dns_name = module.alb.load_balancer_details.dns_name
  load_balancer_zone_id  = module.alb.load_balancer_details.zone_id
  alias_zone_id          = data.aws_route53_zone.alias_hosted_zone.zone_id
  alias_fqdn             = var.route53_alias_settings.alias_fqdn
}

module "cloudwatch" {
  source                 = "./modules/cloudwatch"
  aws_region             = var.aws_region
  dashboard_name         = var.resource_name_prefix
  autoscaling_group_name = module.asg.autoscaling_group_details.name
  load_balancer_arn      = module.alb.load_balancer_details.arn
  target_group_arn       = module.alb.target_group_details.arn
}
