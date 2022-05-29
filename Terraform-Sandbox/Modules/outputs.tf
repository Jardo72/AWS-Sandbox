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

output "vpc" {
  value = {
    id  = aws_vpc.vpc.id,
    arn = aws_vpc.vpc.arn
  }
}

output "public_subnets" {
  value = { for az, subnet in aws_subnet.public_subnet : az => { az = var.availability_zones[az].az_name, subnet_id = subnet.id, subnet_arn = subnet.arn } }
}

output "private_subnets" {
  value = { for az, subnet in aws_subnet.private_subnet : az => { az = var.availability_zones[az].az_name, subnet_id = subnet.id, subnet_arn = subnet.arn } }
}
