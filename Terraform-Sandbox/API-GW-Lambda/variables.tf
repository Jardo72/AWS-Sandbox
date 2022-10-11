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

variable "aws_region" {
  description = "The AWS region where the resources are to be provisioned"
  type        = string
}

variable "ssm_parameter_name_prefix" {
  description = "Prefix for the names of all SSM parameters defined in this configuration"
  type        = string
  default     = "/api-gw-lambda-samples"
}

variable "ssm_parameter_one_name" {
  description = "Short name (without prefix) for the 1st SSM parameter"
  type        = string
  default     = "sample-param-one"
}

variable "ssm_parameter_one_value" {
  description = "The value for the 1st SSM parameter"
  type        = string
  default     = "Sample SSM parameter value #1 for API-GW-Lambda-Demo"
}

variable "ssm_parameter_two_name" {
  description = "Short name (without prefix) for the 2nd SSM parameter"
  type        = string
  default    = "sample-param-two"
}

variable "ssm_parameter_two_value" {
  description = "The value for the 2nd SSM parameter"
  type        = string
  default     = "Second SSM parameter value for API-GW-Lambda-Demo"
}

variable "ssm_parameter_three_name" {
  description = "Short name (without prefix) for the 3rd SSM parameter"
  type        = string
  default    = "sample-param-three"
}

variable "ssm_parameter_three_value" {
  description = "The value for the 3rd SSM parameter"
  type        = string
  default     = "Dummy SSM parameter value #3 for API-GW-Lambda-Demo"
}

variable "resource_name_prefix" {
  description = "Prefix for the names to be applied to the provisioned resources"
  type        = string
}

variable "tags" {
  description = "Common tags to be applied to the provisioned resources"
  type        = map(string)
}
