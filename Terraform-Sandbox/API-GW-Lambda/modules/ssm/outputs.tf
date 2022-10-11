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

output "ssm_parameter_one_name" {
  value = aws_ssm_parameter.ssm_parameter_one.name
}

output "ssm_parameter_two_name" {
  value = aws_ssm_parameter.ssm_parameter_two.name
}

output "ssm_parameter_three_name" {
  value = aws_ssm_parameter.ssm_parameter_three.name
}
