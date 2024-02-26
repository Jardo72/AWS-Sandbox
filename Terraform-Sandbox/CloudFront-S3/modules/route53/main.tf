#
# Copyright 2024 Jaroslav Chmurny
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

// TODO: rename the resource
resource "aws_route53_record" "load_balancer_alias" {
  zone_id = var.alias_zone_id
  name    = var.alias_fqdn
  type    = "A"
  alias {
    name                   = var.cloudfront_dns_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
