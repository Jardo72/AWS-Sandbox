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

variable "dummy_string" {
  description = "Dummy variable of type string"
  type = string
}

variable "dummy_number" {
  description = "Dummy variable of type number"
  type = number
}

variable "dummy_bool" {
  description = "Dummy variable of type bool"
  type = bool
}

variable "dummy_string_list" {
  description = "Dummy variable of type list of string(s)"
  type = list(string)
}

variable "dummy_number_list" {
  description = "Dummy variable of type list of number(s)"
  type = list(number)
}

variable "dummy_object" {
  description = "Dummy variable of type object"
  type = object({
    cidr = string
    az_index = number
  })
}

variable "dummy_map" {
  description = "Dummy variable of type map"
  type = map(any)
}
