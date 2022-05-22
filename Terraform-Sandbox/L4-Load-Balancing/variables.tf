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

# TODO: it does not make that much sense to have a default here
variable "deployment_artifactory_prefix" {
  description = "The prefix of the application JAR file within the S3 bucket which will serve as the artifactory with JAR files"
  type        = string
  default     = "L4-LB-DEMO"
}

# TODO: it does not make that much sense to have a default here
variable "application_jar_file" {
  description = "The name of the application JAR file (fat runnable JAR file is expected)"
  type        = string
  default     = "aws-sandbox-application-load-balancing-server-1.0.jar"
}

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

variable "ec2_instance_type" {
  description = "Instance type for the EC2 instances running the L4 Load-Balancing Demo application"
  type        = string
  default     = "t2.nano"
}

variable "nlb_port" {
  description = "TCP port the load balancer will use to accept incoming connections"
  type        = number
  default     = 1234
}

variable "ec2_port" {
  description = "TCP port the application instances running on EC2 will use to accept incoming connections"
  type        = number
  default     = 1234
}
