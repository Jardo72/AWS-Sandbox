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

variable "hosted_zone_name" {
  description = "The name of the Route 53 hosted zone to be created"
  type        = string
  default     = "example.jch"
}

var "ttl" {
  description = "TTL (in seconds) for the Route 53 record to be created"
  type        = number
  default     = 300
}

variable "ec2_instance_one_ip_address" {
  description = "IP address of the EC2 instance running in VPC #1"
  type        = string
}

variable "ec2_instance_two_ip_address" {
  description = "IP address of the EC2 instance running in VPC #2"
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
