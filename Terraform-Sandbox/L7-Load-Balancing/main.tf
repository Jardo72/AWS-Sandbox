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
  target_group_arn = module.alb.target_group_arn
  application_installation = {
    deployment_artifactory_bucket_name     = ""
    deployment_artifactory_prefix          = ""
    application_jar_file                   = ""
    deployment_artifactory_access_role_arn = ""
  }
  ec2_instance = {
    instance_type = "t2.nano"
    port          = 80
  }
  target_cpu_utilization_threshold = 50 # TODO: take this from a variable
  resource_name_prefix             = var.resource_name_prefix
  tags                             = var.tags
}

module "cloudwatch" {
  source               = "./modules/cloudwatch"
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.tags
}
