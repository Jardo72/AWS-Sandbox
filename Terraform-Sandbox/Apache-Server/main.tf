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

terraform {
  required_version = ">=1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.15.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current_account" {}

data "aws_ami" "latest_amazon_linux_ami" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "random_password" "dummy_password" {
  length  = 12
  special = true
}

resource "aws_ssm_parameter" "dummy_password" {
  description = "Dummy password for no real use"
  type        = "SecureString"
  name        = var.ssm_parameter_name
  value       = random_password.dummy_password.result
  tags        = var.tags
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags                 = var.tags
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.tags
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags                    = var.tags
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = var.tags
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

resource "aws_security_group" "web_server_security_group" {
  name        = "Apache-Demo"
  description = "Allow inbound HTTP(S) traffic from any origin"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      cidr_blocks = ["0.0.0.0/0"]
      description = "Rule #${ingress.key + 1}: ${ingress.value.description}"
    }
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_eip" "web_server_elastic_ip" {
  instance = aws_instance.web_server.id
  vpc      = true
  tags     = var.tags
}

resource "aws_iam_role" "ssm_parameter_reader_role" {
  name = "SSMParameterReaderRole"
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

  inline_policy {
    name = "SSMParameterValueReadAccess"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Sid : "AllowGetParameter",
          Action : ["ssm:GetParameter"]
          Effect : "Allow"
          Resource : format("arn:aws:ssm:%s:%s:parameter%s", var.aws_region, data.aws_caller_identity.current_account.account_id, var.ssm_parameter_name)
        }
      ]
    })
  }

  # needed in order to be able to connect to the instance via the Session Manager
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  ]

  tags = var.tags
}

resource "aws_iam_instance_profile" "ssm_parameter_reader_profile" {
  name = "SSMParameterReaderProfile"
  role = aws_iam_role.ssm_parameter_reader_role.name
  tags = var.tags
}

resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.latest_amazon_linux_ami.id
  instance_type               = "t2.nano"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_server_security_group.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_parameter_reader_profile.name
  user_data_replace_on_change = true
  user_data = templatefile("user-data.tpl", {
    aws_region         = var.aws_region
    ssm_parameter_name = var.ssm_parameter_name
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_ssm_parameter.dummy_password]
}

resource "null_resource" "web_server_status_ok" {
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.web_server.id}"
  }
  depends_on = [aws_instance.web_server]
}
