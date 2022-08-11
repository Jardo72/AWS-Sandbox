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

output "vpc_one_vpc_id" {
  value = module.vpc_one.vpc_id
}

output "vpc_one_subnet_id" {
  value = module.vpc_one.private_subnets[0]
}

output "vpc_two_vpc_id" {
  value = module.vpc_two.vpc_id
}

output "vpc_two_subnet_id" {
  value = module.vpc_two.private_subnets[0]
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.vpc_peering.id
}
