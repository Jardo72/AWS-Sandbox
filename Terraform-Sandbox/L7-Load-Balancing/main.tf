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

provider "aws" {
  region = var.aws_region
}

data "aws_cloudformation_export" "deployment_artifactory_bucket_name" {
  name = "CommonDeploymentArtifactoryBucketName"
}

data "aws_cloudformation_export" "deployment_artifactory_read_access_policy_arn" {
  name = "CommonDeploymentArtifactoryReadAccessPolicyArn"
}

data "aws_route53_zone" "alias_hosted_zone" {
  # TODO: take the name from a variable
  name         = "jardo72.de."
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
  source     = "./modules/alb"
  vpc_id     = module.vpc.vpc_details.id
  subnet_ids = values(module.vpc.subnets)[*].subnet_id
  alb_listener_settings = {
    port     = 80 # TODO: take this from a variable
    protocol = "HTTP"
  }
  target_ec2_settings = {
    port                  = 80 # TODO: take this from a variable
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
  source           = "./modules/asg"
  vpc_id           = module.vpc.vpc_details.id
  subnet_ids       = values(module.vpc.subnets)[*].subnet_id
  target_group_arn = module.alb.target_group_details.arn
  application_installation = {
    # TODO: take the hardcoded values from variables
    deployment_artifactory_bucket_name     = data.aws_cloudformation_export.deployment_artifactory_bucket_name.value
    deployment_artifactory_prefix          = "L7-LB-DEMO"
    application_jar_file                   = "aws-sandbox-application-load-balancing-server-1.0.jar"
    deployment_artifactory_access_role_arn = data.aws_cloudformation_export.deployment_artifactory_read_access_policy_arn.value
  }
  ec2_instance = {
    # TODO: take the settings from variables
    instance_type = "t2.nano"
    port          = 80
  }
  autoscaling_group = {
    # TODO: take the settings from variables
    min_size                         = 3
    max_size                         = 6
    desired_capacity                 = 3
    target_cpu_utilization_threshold = 50
  }
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}

module "route53" {
  source                 = "./modules/route53"
  load_balancer_dns_name = module.alb.load_balancer_details.dns_name
  load_balancer_zone_id  = module.alb.load_balancer_details.zone_id
  alias_zone_id          = data.aws_route53_zone.alias_hosted_zone.zone_id
  # TODO: take the settings from variables
  alias_fqdn = "alb-demo.jardo72.de"
}

module "cloudwatch" {
  source                 = "./modules/cloudwatch"
  aws_region             = var.aws_region
  dashboard_name         = var.resource_name_prefix
  autoscaling_group_name = module.asg.autoscaling_group_details.name
  load_balancer_arn      = module.alb.load_balancer_details.arn
  target_group_arn       = module.alb.target_group_details.arn
}
