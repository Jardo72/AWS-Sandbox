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
  region = "eu-central-1"
}

locals {
  parameter_name_prefix = "/terraform-cloud-demo/${terraform.workspace}"
  common_tags = {
    Stack         = "Terraform-Cloud-Demo",
    ProvisionedBy = "Terraform"
    Workspace     = "${terraform.workspace}"
  }
}

data "aws_caller_identity" "current_account" {}

resource "aws_ssm_parameter" "demo_standalone_parameter" {
  description = "Demo parameter with value from Terraform variable"
  type        = "String"
  name        = "${local.parameter_name_prefix}/standalone-param"
  value       = var.standalone_parameter_value
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "demo_map_driven_parameter" {
  for_each    = var.parameter_definition
  description = each.value.description
  type        = each.value.type
  name        = "${local.parameter_name_prefix}/${each.value.short_name}"
  value       = each.value.value
  tags        = merge(local.common_tags, {
      DefinitionKey = each.key
  })
}
