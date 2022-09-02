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

variable "read_ssm_parameter_function_arn" {
  description = "ARN of the Lambda function to be used as backend for the read SSM paramater API endpoint"
  type        = string
}

variable "kms_encryption_function_arn" {
  description = "ARN of the Lambda function to be used as backend for the KMS encryption API endpoint"
  type        = string
}

variable "kms_decryption_function_arn" {
  description = "ARN of the Lambda function to be used as backend for the KMS decryption API endpoint"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix for the names to be applied to the provisioned resources"
  type        = string
}

variable "tags" {
  description = "Common tags to be applied to the provisioned resources"
  type        = map(string)
}
