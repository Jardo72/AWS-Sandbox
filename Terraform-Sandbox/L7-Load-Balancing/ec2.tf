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
  template = templatefile("user-data.tpl", {
    deployment_artifactory_bucket = data.aws_cloudformation_export.deployment_artifactory_bucket_name.value
    deployment_artifactory_prefix = var.deployment_artifactory_prefix,
    application_jar_file          = var.application_jar_file,
    ec2_port                      = var.ec2_port
  })
}

resource "aws_iam_role" "ec2_iam_role" {
  name = "${local.name_prefix}-EC2-IAM-Role"
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
    data.aws_cloudformation_export.deployment_artifactory_read_access_policy_arn.value
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-EC2-IAM-Role"
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${local.name_prefix}-EC2-Instance-Profile"
  role = aws_iam_role.ec2_iam_role.name
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-EC2-Instance-Profile"
  })
}

resource "aws_launch_template" "ec2_launch_template" {
  name                   = "${local.name_prefix}-Launch-Template"
  image_id               = data.aws_ami.latest_amazon_linux_ami.id
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_instance_profile.arn
  }
  update_default_version = true
  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }
  user_data = base64encode(data.template_file.ec2_user_data.rendered)
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Launch-Template"
  })
}

resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name                      = "${local.name_prefix}-ASG"
  min_size                  = 3
  max_size                  = 6
  desired_capacity          = 3
  health_check_type         = "ELB"
  health_check_grace_period = 150
  vpc_zone_identifier       = [for subnet in aws_subnet.public_subnet : subnet.id]
  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.alb_target_group.arn]
  # tag = local.common_tags
}

resource "aws_autoscaling_policy" "ec2_scaling_policy" {
  name                   = "${local.name_prefix}-Scaling-Policy"
  autoscaling_group_name = aws_autoscaling_group.ec2_autoscaling_group.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value     = var.target_cpu_utilization_threshold
    disable_scale_in = false
  }
}

# https://skillmix.io/terraform/lab-multi-resource-terraform-project/
# https://blog.imfiny.com/imfiny-aws-terraform-2019-01-18-aws-launch-templates-html/
