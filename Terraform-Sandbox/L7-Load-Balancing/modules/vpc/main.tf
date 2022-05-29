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

resource "aws_subnet" "subnet" {
  for_each                = var.availability_zones
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.name
  cidr_block              = each.value.subnet_cidr_block
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-Subnet-${each.key}"
  })
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-Route-Table"
  })
}

resource "aws_route_table_association" "route_table_association" {
  for_each       = local.availability_zones
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.route_table.id
}
