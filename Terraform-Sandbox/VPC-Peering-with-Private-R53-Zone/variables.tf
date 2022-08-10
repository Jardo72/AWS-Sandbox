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

variable "vpc_one_cidr_block" {
  description = "CIDR block for the first of the two VPCs"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_two_cidr_block" {
  description = "CIDR block for the second of the two VPCs"
  type        = string
  default     = "10.1.0.0/16"
}

variable "ec2_instance_type" {
  description = "Instance type of the EC2 instances to be started"
  type        = string
  default     = "t2.micro"
}

variable "hosted_zone_name" {
  description = "The name of the Route 53 hosted zone to be created"
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
