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

data "aws_caller_identity" "current" {}

module "ssm" {
  source                = "./modules/ssm"
  parameter_name_prefix = var.ssm_parameter_name_prefix
  parameter_one_name    = var.ssm_parameter_one_name
  parameter_one_value   = var.ssm_parameter_one_value
  parameter_two_name    = var.ssm_parameter_two_name
  parameter_two_value   = var.ssm_parameter_two_value
  parameter_three_name  = var.ssm_parameter_three_name
  parameter_three_value = var.ssm_parameter_three_value
  resource_name_prefix  = var.resource_name_prefix
  tags                  = var.tags
}

module "lambda" {
  source                    = "./modules/lambda"
  aws_region                = var.aws_region
  aws_account_id            = data.aws_caller_identity.current.account_id
  ssm_parameter_name_prefix = var.ssm_parameter_name_prefix
  resource_name_prefix      = var.resource_name_prefix
  tags                      = var.tags
}

module "api-gw" {
  source                          = "./modules/api-gw"
  aws_region                      = var.aws_region
  read_ssm_parameter_function_arn = module.lambda.read_ssm_parameter_function_arn
  kms_encryption_function_arn     = module.lambda.kms_encryption_function_arn
  kms_decryption_function_arn     = module.lambda.kms_decryption_function_arn
  resource_name_prefix            = var.resource_name_prefix
  tags                            = var.tags
}
