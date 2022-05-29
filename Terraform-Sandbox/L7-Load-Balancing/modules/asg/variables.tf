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
    deployment_artifactory_bucket_name = string
    deployment_artifactory_prefix      = string
    application_jar_file               = string
  })
}

variable "ec2_instance_type" {
  description = "Instance type for the EC2 instances comprising the auto-scaling group"
  type        = string
  default     = "t2.nano"
}

variable "ec2_port" {
  description = "TCP port for the application"
  type        = number
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

variable "target_cpu_utilization_threshold" {
  description = "Threshold for the aggregate CPU utilization for the autoscaling group; if the CPU utilization will exceed this value, autoscaling will scale out the autoscaling group"
  type        = number
}

variable "resource_name_prefix" {
  description = "Prefix for the names to be applied to the provisioned resources"
  type        = string
}

variable "tags" {
  description = "Common tags to be applied to the provisioned resources"
  type        = map(string)
}