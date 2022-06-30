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

variable "enabled" {
  description = "Determines whether the Route 53 alias for the NLB is to be created or not"
  type        = bool
}

variable "load_balancer_dns_name" {
  description = "AWS-assigned DNS name of the ALB"
  type        = string
}

variable "load_balancer_zone_id" {
  description = "The zone ID of the AWS-managed hosted zone containing the record with the AWS-assigned DNS name of the ALB"
  type        = string
}

variable "alias_zone_id" {
  description = "Zone ID of the hosted zone the alias record is to be added to"
  type        = string
}

variable "alias_fqdn" {
  description = "FQDN for the alias record"
  type        = string
}
