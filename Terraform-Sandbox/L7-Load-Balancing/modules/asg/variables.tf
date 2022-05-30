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

variable "application_installation" {
  description = "Settings for the installation of the application"
  type        = object({
    deployment_artifactory_bucket_name     = string
    deployment_artifactory_prefix          = string
    application_jar_file                   = string
    deployment_artifactory_access_role_arn = string
  })
}

variable "ec2_instance" {
  description = "Settings for the EC2 instances comprising the auto-scaling group"
  type        = object({
    instance_type = string
    port          = number
  })
}

variable "autoscaling_group" {
  description = "Settings for the auto-scaling group"
  type        = object({
    min_size                         = number
    max_size                         = number
    desired_capacity                 = number
    target_cpu_utilization_threshold = number
  })
}

variable vpc_id {
  description = "VPC ID of the VPC hosting the application"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets to be used by the auto-scaling group"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group "
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
