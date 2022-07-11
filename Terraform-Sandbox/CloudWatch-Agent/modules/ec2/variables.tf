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
  description = "The name of the AWS region where the application is running"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC the EC2 instance(s) are to be launched in"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet the EC2 instance(s) are to be launched in"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances to be started"
  type        = string
  default     = "t2.nano"
}

variable "resource_name_prefix" {
  description = "Prefix for the names to be applied to the provisioned resources"
  type        = string
}

variable "tags" {
  description = "Common tags to be applied to the provisioned resources"
  type        = map(string)
}