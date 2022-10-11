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

resource "aws_ssm_parameter" "ssm_parameter_one" {
  type  = "String"
  tier  = "Standard"
  name  = "${var.parameter_name_prefix}/${var.parameter_one_name}"
  value = var.parameter_one_value
  tags  = var.tags
}

resource "aws_ssm_parameter" "ssm_parameter_two" {
  type  = "String"
  tier  = "Standard"
  name  = "${var.parameter_name_prefix}/${var.parameter_two_name}"
  value = var.parameter_two_value
  tags  = var.tags
}

resource "aws_ssm_parameter" "ssm_parameter_three" {
  type  = "String"
  tier  = "Standard"
  name  = "${var.parameter_name_prefix}/${var.parameter_three_name}"
  value = var.parameter_three_value
  tags  = var.tags
}
