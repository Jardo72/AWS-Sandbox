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

output "dummy_string_value" {
  value = var.dummy_string
}

output "dummy_number_value" {
  value = var.dummy_number
}

output "dummy_bool_value" {
  value = var.dummy_bool
}

output "dummy_string_list_value" {
  value = var.dummy_string_list
}

output "dummy_number_list_value" {
  value = var.dummy_number_list
}

output "dummy_object_value" {
  value = var.dummy_object
}

output "dummy_map_value" {
  value = var.dummy_map
}

output "dummy_tuple_value" {
  value = var.dummy_tuple
}

output "dummy_set_value" {
  value = var.dummy_set
}

output "dummy_sensitive_value" {
  value     = var.dummy_sensitive_string
  sensitive = true
}

output "dummy_sensitive_value_revealed" {
  value = nonsensitive(var.dummy_sensitive_string)
}
