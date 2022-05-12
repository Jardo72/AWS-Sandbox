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

  /* TODO: remove or adapt to what is really needed
  inline_policy {
    name = "SSMParameterValueReadAccess"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Sid : "AllowGetParameter",
          Action : ["ssm:GetParameter"]
          Effect : "Allow"
          Resource : format("arn:aws:ssm:%s:%s:parameter%s", local.aws_region, data.aws_caller_identity.current_account.account_id, local.ssm_parameter_name)
        }
      ]
    })
  } */

  # needed in order to be able to connect to the instance via the Session Manager
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
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
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Launch-Template"
  })
}

/*
resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name                      = "${local.name_prefix}-Auto-Scaling-Group"
  min_size                  = 3
  max_size                  = 6
  desired_capacity          = 3
  health_check_type         = "ELB"
  health_check_grace_period = 150
  vpc_zone_identifier       = [
    data.aws_availability_zones.available.ids[0],
    data.aws_availability_zones.available.ids[1],
    data.aws_availability_zones.available.ids[2]
  ]
  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = aws_launch_template.ec2_launch_template.latest_version
  }
  tags = local.common_tags
} */
