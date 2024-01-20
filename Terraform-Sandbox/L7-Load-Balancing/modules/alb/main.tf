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

resource "aws_security_group" "security_group" {
  name        = "${var.resource_name_prefix}-ALB-SG"
  description = "Security group for the ALB"
  vpc_id      = var.vpc_id
  ingress {
    protocol    = "tcp"
    from_port   = var.alb_listener_settings.port
    to_port     = var.alb_listener_settings.port
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound traffic from anywhere to the ALB TCP port"
  }
  egress {
    protocol    = "tcp"
    from_port   = var.target_ec2_settings.port
    to_port     = var.target_ec2_settings.port
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow outbound traffic within the VPC to the EC2 TCP port"
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-ALB-SG"
  })
}

resource "aws_lb" "load_balancer" {
  name               = "${var.resource_name_prefix}-ALB"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.security_group.id]
  access_logs {
    bucket  = var.alb_access_log_settings.bucket_name
    prefix  = var.alb_access_log_settings.prefix
    enabled = var.alb_access_log_settings.enabled
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-ALB"
  })
}

resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.alb_listener_settings.port
  protocol          = var.alb_listener_settings.protocol
  certificate_arn   = var.alb_listener_settings.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.resource_name_prefix}-ALB-TG"
  vpc_id   = var.vpc_id
  port     = var.target_ec2_settings.port
  protocol = var.target_ec2_settings.protocol
  health_check {
    enabled             = true
    healthy_threshold   = var.target_ec2_settings.healthy_threshold
    unhealthy_threshold = var.target_ec2_settings.unhealthy_threshold
    interval            = var.target_ec2_settings.health_check_interval
    timeout             = var.target_ec2_settings.health_check_timeout
    path                = var.target_ec2_settings.health_check_path
    matcher             = var.target_ec2_settings.health_check_matcher
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-ALB-TG"
  })
}
