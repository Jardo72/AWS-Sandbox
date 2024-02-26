#
# Copyright 2024 Jaroslav Chmurny
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

variable "webcontent_bucket_name" {
  description = "Name of the bucket storing the web content (serving as origin for the CloudFront distribution)"
  type        = string
}

variable "alias_hosted_zone_name" {
  description = "The name of the Route 53 hosted zone the Route 53 alias is to be added to"
  type        = string
}

variable "dns_alias_fqdn" {
  description = "FQDN for the Route 53 alias record"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate to be used"
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
