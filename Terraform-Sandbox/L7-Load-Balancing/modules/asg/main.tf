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
    data.aws_cloudformation_export.deployment_artifactory_read_access_policy_arn.value
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

resource "aws_launch_template" "ec2_launch_template" {
  name                   = "${var.resource_name_prefix}-Launch-Template"
  image_id               = data.aws_ami.latest_amazon_linux_ami.id
  instance_type          = var.ec2_instance_type
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

resource "aws_security_group" "security_group" {
  name        = "${var.resource_name_prefix}-EC2-SG"
  description = "Allow inbound HTTP traffic from the ALB for the EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.ec2_port
    to_port          = var.ec2_port
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
