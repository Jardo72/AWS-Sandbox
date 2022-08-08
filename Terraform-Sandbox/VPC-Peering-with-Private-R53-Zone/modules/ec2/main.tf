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
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
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

resource "aws_security_group" "ec2_one_security_group" {
  name        = "${var.resource_name_prefix}-EC2-#1-SG"
  description = "Allow inbound ICMP traffic from the peered VPC"
  vpc_id      = var.vpc_one_vpc_id
  ingress {
    protocol    = "icmp"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_two_cidr_block]
    description = "Allow inbound ICMP traffic from the peered VPC"
  }
  egress {
    protocol    = "icmp"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_two_cidr_block]
    description = "Allow outbound ICMP traffic to the peered VPC"
  }
  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound HTTPS traffic (needed for the SSM Agent)"
  }
  egress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_two_cidr_block]
    description = "Allow outbound TCP traffic to the peered VPC"
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-EC2-#1-SG"
  })
}

resource "aws_security_group" "ec2_two_security_group" {
  name        = "${var.resource_name_prefix}-EC2-#2-SG"
  description = "Allow inbound ICMP traffic from the peered VPC"
  vpc_id      = var.vpc_two_vpc_id
  ingress {
    protocol    = "icmp"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_one_cidr_block]
    description = "Allow inbound ICMP traffic from the peered VPC"
  }
  egress {
    protocol    = "icmp"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_two_cidr_block]
    description = "Allow outbound ICMP traffic to the peered VPC"
  }
  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound HTTPS traffic (needed for the SSM Agent)"
  }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 100
    cidr_blocks = [var.vpc_one_cidr_block]
    description = "Allow inbound TCP traffic from the peered VPC for ports between 80 and 100"
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-EC2-#2-SG"
  })
}

resource "aws_instance" "ec2_instance_one" {
  ami                    = data.aws_ami.latest_amazon_linux_ami.id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.vpc_one_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_one_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = templatefile("${path.module}/ec2-user-data.tftpl", {})
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-EC2-#1"
  })
}

resource "aws_instance" "ec2_instance_two" {
  ami                    = data.aws_ami.latest_amazon_linux_ami.id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.vpc_two_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_two_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = templatefile("${path.module}/ec2-user-data.tftpl", {})
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-EC2-#2"
  })
}
