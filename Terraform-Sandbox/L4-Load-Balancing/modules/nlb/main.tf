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

resource "aws_lb" "load_balancer" {
  name               = "${var.resource_name_prefix}-NLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-NLB"
  })
}

resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.nlb_port
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.resource_name_prefix}-NLBTargetGroup"
  vpc_id   = var.vpc_id
  port     = var.target_ec2_settings.port
  protocol = "TCP"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    /* TODO: this seems to cause troubles, but it works with CloudFormation
    interval            = 30
    timeout             = 10 */
  }
}
