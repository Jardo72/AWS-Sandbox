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

resource "aws_route53_zone" "private_hosted_zone" {
  name    = var.hosted_zone_name
  comment = "Experimental private hosted zone for peered VPCs (${var.resource_name_prefix} demo)"
  vpc {
    vpc_id = module.vpc_one.vpc_id
  }
  vpc {
    vpc_id = module.vpc_two.vpc_id
  }
  tags = var.tags
}

resource "aws_route53_record" "ec2_instance_one_record" {
  zone_id = aws_route53_zone.private_hosted_zone.zone_id
  name    = "ec2-one.${var.hosted_zone_name}"
  type    = "A"
  ttl     = 300
  reords  = [var.ec2_instance_one_ip_address]
}

resource "aws_route53_record" "ec2_instance_two_record" {
  zone_id = aws_route53_zone.private_hosted_zone.zone_id
  name    = "ec2-two.${var.hosted_zone_name}"
  type    = "A"
  ttl     = 300
  reords  = [var.ec2_instance_two_ip_address]
}
