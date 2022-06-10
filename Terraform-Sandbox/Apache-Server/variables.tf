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
  description = "AWS region where the resources are to be provisioned"
  type        = string
  default     = "eu-central-1"
}

variable "ssm_parameter_name" {
  description = "The name of the SSM parameter to be created"
  type        = string
  default     = "/terraform-sandbox/apache-server/dummy-password"
}

variable "ingress_rules" {
  description = "Ingress rules for the security group protecting the EC2 instance running the Apache server"
  type = list(object({
    protocol    = string,
    port        = number,
    description = string
  }))
  default = [
    {
      protocol    = "tcp",
      port        = 80,
      description = "Allow inbound HTTP from anywhere"
    },
    {
      protocol    = "tcp",
      port        = 443,
      description = "Allow inbound HTTPS from anywhere"
    }
  ]
}

variable "tags" {
  description = "Common tags to be applied to the provisioned resources"
  type        = map(string)
  default = {
    Stack         = "Apache-Demo",
    ProvisionedBy = "Terraform"
  }
}
