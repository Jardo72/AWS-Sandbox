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

data "aws_ami" "latest_amazon_linux_ami" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "template_file" "ec2_user_data" {
  template = templatefile("${path.module}/user-data.tftpl", {
    deployment_artifactory_bucket = var.application_installation.deployment_artifactory_bucket_name
    deployment_artifactory_prefix = var.application_installation.deployment_artifactory_prefix,
    application_jar_file          = var.application_installation.application_jar_file,
    ec2_port                      = var.ec2_instance.port
  })
}

resource "aws_iam_role" "ec2_iam_role" {
  name = "${var.resource_name_prefix}-EC2-IAM-Role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowEC2Assume",
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Effect : "Allow"
      }
    ]
  })

  managed_policy_arns = [
    # needed in order to be able to connect to the EC2 instances via the SSM Session Manager
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    var.application_installation.deployment_artifactory_access_role_arn
  ]

  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-EC2-IAM-Role"
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.resource_name_prefix}-EC2-Instance-Profile"
  role = aws_iam_role.ec2_iam_role.name
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-EC2-Instance-Profile"
  })
}

resource "aws_security_group" "security_group" {
  name        = "${var.resource_name_prefix}-EC2-SG"
  description = "Allow inbound HTTP traffic from the ALB for the EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.ec2_instance.port
    to_port          = var.ec2_instance.port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-EC2-SG"
  })
}

resource "aws_launch_template" "launch_template" {
  name                   = "${var.resource_name_prefix}-Launch-Template"
  image_id               = data.aws_ami.latest_amazon_linux_ami.id
  instance_type          = var.ec2_instance.instance_type
  vpc_security_group_ids = [aws_security_group.security_group.id]
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_instance_profile.arn
  }
  update_default_version = true
  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }
  user_data = base64encode(data.template_file.ec2_user_data.rendered)
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-Launch-Template"
  })
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "${var.resource_name_prefix}-ASG"

  # TODO: this should be taken from variables
  min_size                  = 3
  max_size                  = 6
  desired_capacity          = 3

  health_check_type         = "ELB"
  health_check_grace_period = 150
  vpc_zone_identifier       = var.subnet_ids
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  target_group_arns = [var.target_group_arn]
  # TODO: make it work, or remove it
  # tag = var.tags
}

resource "aws_autoscaling_policy" "scaling_policy" {
  name                   = "${var.resource_name_prefix}-Scaling-Policy"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value     = var.target_cpu_utilization_threshold
    disable_scale_in = false
  }
}
