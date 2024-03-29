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

output "read_ssm_parameter_function_arn" {
  value = aws_lambda_function.read_ssm_parameter_function.arn
}

output "kms_encryption_function_arn" {
  value = aws_lambda_function.kms_encryption_function.arn
}

output "kms_decryption_function_arn" {
  value = aws_lambda_function.kms_decryption_function.arn
}
