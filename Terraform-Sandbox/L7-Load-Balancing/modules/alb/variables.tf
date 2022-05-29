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

variable vpc_id {
  description = "VPC ID of the VPC hosting the application"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets to be used by the load balancer"
  type        = list(string)
}

variable "alb_listener_settings" {
  description = "Protocol and TCP port for the ALB listener"
  type        = object({
    port     = number
    protocol = string
  })
}

variable "target_ec2_settings" {
  description = "Protocol and TCP port for the target EC2 instances"
  type        = object({
    port                  = number
    protocol              = string
    healthy_threshold     = number
    unhealthy_threshold   = number
    health_check_interval = number
    health_check_timeout  = number
    health_check_path     = string
    health_check_matcher  = string
  })
}

variable "resource_name_prefix" {
  description = "Prefix for the names to be applied to the provisioned resources"
  type        = string
}

variable "tags" {
  description = "Common tags to be applied to the provisioned resources"
  type        = map(string)
}
