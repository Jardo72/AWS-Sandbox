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
  default     = "eu-central-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC (default = 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Definition of subnets for particular availability zones"
  type = map(object({
    az_name                   = string
    public_subnet_cidr_block  = string
    private_subnet_cidr_block = string
  }))
}

variable "application_installation" {
  description = "Settings for the installation of the application"
  type = object({
    deployment_artifactory_bucket_name_export     = string
    deployment_artifactory_access_role_arn_export = string
    deployment_artifactory_prefix                 = string
    application_jar_file                          = string
  })
}

variable "ec2_settings" {
  description = "Settings for the EC2 instances comprising the EC2 ASG"
  type = object({
    instance_type = string
    port          = number
  })
}

variable "nlb_port" {
  description = "TCP port the load balancer will use to accept incoming connections"
  type        = number
  default     = 1234
}

variable "route53_alias_settings" {
  description = "Settings for the Route 53 alias for the ALB"
  type = object({
    alias_hosted_zone_name = string
    alias_fqdn             = string
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
