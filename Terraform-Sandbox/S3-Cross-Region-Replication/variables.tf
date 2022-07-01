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
  type    = string
  default = "eu-central-1"
}

variable "source_bucket_details" {
  description = "Details of the source S3 bucket from which objects will be replicated"
  type = object({
    bucket_name = string
    aws_region  = string
  })
}

variable "destination_bucket_details" {
  description = "Details of the destination S3 bucket to which objects will be replicated"
  type = object({
    bucket_name = string
    aws_region  = string
  })
}

variable "tags" {
  description = "Common tags to be applied to the provisioned resources"
  type        = map(string)
}
