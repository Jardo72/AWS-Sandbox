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

dummy_string = "Good morning Terraform"
dummy_number = 4321
dummy_bool   = false

dummy_string_list = ["S", "M", "L"]
dummy_number_list = [1, 3, 5, 7, 11, 13]

dummy_object = {
  cidr     = "192.168.1.0/24"
  az_index = 0
}

dummy_map = {
  string_value = "alternative string",
  number_value = 4321,
  bool_value   = true
}

dummy_tuple = ["bye", 4321, false]

dummy_set = ["red", "green", "blue", "red", "blue"]

dummy_validated_number = 3
