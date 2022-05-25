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

dummy_string = "Hello Terraform"
dummy_number = 1234
dummy_bool   = true

dummy_string_list = ["red", "green", "blue"]
dummy_number_list = [1, 2, 4, 8, 16, 32]

dummy_object = {
  cidr     = "10.0.1.0/24"
  az_index = 0
}

dummy_map = {
  string_value = "dummy string",
  number_value = 1234,
  bool_value : false
}

dummy_tuple = ["hello", 1234, true]

dummy_set = ["red", "green", "blue", "green"]

dummy_validated_number = 7