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

provider "aws" {
  region = "eu-central-1"
}

variable "dummy_map" {
  description = "Dummy map with default value used to demonstrate for loop"
  type = map(string)
  default = {
    "color" = "blue"
    "size" = "XXL"
    "brand" = "Adidas"
  }
}

resource "aws_iam_user" "count_user" {
  count         = 3
  name          = "CNT-USER-${count.index + 1}"
  force_destroy = true
  tags = {
    Index         = "${count.index}"
    ProvisionedBy = "Terraform"
  }
}

resource "aws_iam_user" "for_each_user" {
  for_each      = toset(["01", "02", "03"])
  name          = "FOR-EACH-USER-${each.key}"
  force_destroy = true
  tags = {
    Key           = "${each.key}"
    Value         = "${each.value}"
    ProvisionedBy = "Terraform"
  }
}

output "iam_count_user_names" {
  value = aws_iam_user.count_user[*].name
}

output "iam_count_user_arns" {
  value = aws_iam_user.count_user[*].arn
}

output "iam_for_each_user_names" {
  value = values(aws_iam_user.for_each_user)[*].name
}

output "iam_for_each_user_arns" {
  value = values(aws_iam_user.for_each_user)[*].arn
}

output "iam_count_user_names_as_csv" {
  value = join(", ", [for iam_user in aws_iam_user.count_user[*] : iam_user.name])
}

output "map_key_value_string" {
  value = join("; ", [for k, v in var.dummy_map: "${k} = ${v}"])
}
