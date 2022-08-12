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

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-VPC"
  })
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-IGW"
  })
}

resource "aws_subnet" "public_subnet" {
  for_each                = var.availability_zones
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.az_name
  cidr_block              = each.value.public_subnet_cidr_block
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-Public-Subnet-${each.key}"
  })
}

resource "aws_subnet" "private_subnet" {
  for_each                = var.availability_zones
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.az_name
  cidr_block              = each.value.private_subnet_cidr_block
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-Private-Subnet-${each.key}"
  })
}

resource "aws_eip" "nat_gateway_elastic_ip" {
  for_each = var.availability_zones
  vpc      = true
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-Elastic-IP-${each.key}"
  })
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each      = var.availability_zones
  allocation_id = aws_eip.nat_gateway_elastic_ip[each.key].id
  subnet_id     = aws_subnet.public_subnet[each.key].id
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-NAT-GW-${each.key}"
  })
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-Public-Route-Table"
  })
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  for_each       = var.availability_zones
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_subnets_route_table.id
}

resource "aws_route_table" "private_subnet_route_table" {
  for_each = var.availability_zones
  vpc_id   = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway[each.key].id
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-Private-Route-Table-${each.key}"
  })
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  for_each       = var.availability_zones
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private_subnet_route_table[each.key].id
}

resource "aws_cloudwatch_log_group" "vpc_flow_log_cw_log_group" {
  name = "${var.resource_name_prefix}-VPC-Flow-CW-Log-Group-${uuid()}"
  retention_in_days = 3
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-VPC-Flow-Log-CW-Log-Group"
  })
}

resource "aws_iam_role" "vpc_flow_log_writer_role" {
  name = "${var.resource_name_prefix}-VPC-Flow-Log-Writer"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowFlowLogAssume",
        Effect : "Allow",
        Action : "sts:AssumeRole",
        Principal : {
          Service : "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "AllowAccessToVpcFlowLogGroup"
    policy = jsonencode({
      Version: "2012-10-17",
      Statement: [
        {
          Sid : "AllowLogOperations",
          Effect: "Allow",
          Action: [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
          ],
          Resource: "*"
        }
      ]
    })
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-VPC-Flow-Log-Writer"
  })
}

resource "aws_flow_log" "vpc_flow_log" {
  vpc_id          = aws_vpc.vpc.id
  iam_role_arn    = aws_iam_role.vpc_flow_log_writer_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_cw_log_group.arn
  traffic_type    = "ALL"
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-VPC-Flow-Log"
  })
  depends_on = [
    aws_cloudwatch_log_group.vpc_flow_log_cw_log_group,
    aws_iam_role.vpc_flow_log_writer_role,
    aws_vpc.vpc
  ]
}
