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

variable "vpc_one_vpc_id" {
  description = "VPC ID of the VPC #1"
  type        = string
}

variable "vpc_two_vpc_id" {
  description = "VPC ID of the VPC #2"
  type        = string
}

variable "vpc_one_cidr_block" {
  description = "CIDR block for the VPC #1"
  type        = string
}

variable "vpc_two_cidr_block" {
  description = "CIDR block for the VPC #2"
  type        = string
}

variable "vpc_one_subnet_id" {
  description = "Subnet ID of the subnet within the VPC #1 where the EC2 instance #1 is to be launched"
  type        = string
}

variable "vpc_two_subnet_id" {
  description = "Subnet ID of the subnet within the VPC #2 where the EC2 instance #1 is to be launched"
  type        = string
}

variable "ec2_instance_type" {
  description = "Instance type of the EC2 instances to be started"
  type        = string
  default     = "t2.micro"
}

variable "resource_name_prefix" {
  description = "Prefix for the names to be applied to the provisioned resources"
  type        = string
}

variable "tags" {
  description = "Common tags to be applied to the provisioned resources"
  type        = map(string)
}
