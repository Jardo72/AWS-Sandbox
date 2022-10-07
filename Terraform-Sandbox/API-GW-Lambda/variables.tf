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

variable "route53_alias_enabled" {
  description = "Determines whether Route 53 alias for the REST API is to be created or not"
  type        = bool
  
  // TODO: remove
  default     = false
}

variable "route53_alias_hosted_zone_name" {
  description = ""
  type        = string
  
  // TODO: remove
  default     = "jardo72.de."
}

variable "route53_alias_fqdn" {
  description = ""
  type        = string
  
  // TODO: remove
  default     = "api-gw-demo.jardo72.de"
}

variable "resource_name_prefix" {
  description = "Prefix for the names to be applied to the provisioned resources"
  type        = string
}

variable "tags" {
  description = "Common tags to be applied to the provisioned resources"
  type        = map(string)
}
