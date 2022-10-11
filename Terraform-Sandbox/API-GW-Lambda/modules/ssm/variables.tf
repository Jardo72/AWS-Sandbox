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

variable "parameter_name_prefix" {
  description = "The prefix (path) for the names of the parameters"
  type        = string
}

variable "parameter_one_name" {
  description = "The short name (without any prefix) of the 1st parameter"
  type        = string
}

variable "parameter_one_value" {
  description = "The value of the 1st parameter"
  type        = string
}

variable "parameter_two_name" {
  description = "The short name (without any prefix) of the 2nd parameter"
  type        = string
}

variable "parameter_two_value" {
  description = "The value of the 2nd parameter"
  type        = string
}

variable "parameter_three_name" {
  description = "The short name (without any prefix) of the 3rd parameter"
  type        = string
}

variable "parameter_three_value" {
  description = "The value of the 3rd parameter"
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
