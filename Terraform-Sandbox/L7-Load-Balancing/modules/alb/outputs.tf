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

output "load_balancer_details" {
  value = {
    dns_name = aws_lb.load_balancer.dns_name
    arn      = aws_lb.load_balancer.arn
    zone_id  = aws_lb.load_balancer.zone_id
  }
}

output "target_group_details" {
  value = {
    arn = aws_lb_target_group.target_group.arn
  }
}

output "load_balancer_security_group_id" {
  value = aws_security_group.security_group.id
}
