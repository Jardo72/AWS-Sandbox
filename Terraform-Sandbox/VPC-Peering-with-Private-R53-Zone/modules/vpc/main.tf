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

data "aws_availability_zones" "available" {}

resource "aws_cloudwatch_log_group" "vpc_one_flow_log_cw_log_group" {
  name              = "${var.resource_name_prefix}-VPC-Flow-Log-1-${uuid()}"
  retention_in_days = 3
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-VPC-Flow-Log-VPC-1"
  })
}

resource "aws_cloudwatch_log_group" "vpc_two_flow_log_cw_log_group" {
  name              = "${var.resource_name_prefix}-VPC-Flow-Log-2-${uuid()}"
  retention_in_days = 3
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-VPC-Flow-Log-VPC-2"
  })
}

resource "aws_iam_role" "vpc_flow_log_writer_role" {
  name = "${var.resource_name_prefix}-VPC-Flow-Log-Writer"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowFlowLogAssume",
        Action : "sts:AssumeRole",
        Principal : {
          Service : "vpc-flow-logs.amazonaws.com"
        },
        Effect : "Allow"
      }
    ]
  })
  inline_policy {
    name = "AllowAccessToVpcFlowLogGroup"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Action : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
          ],
          Effect : "Allow",
          Resource : "*"
        }
      ]
    })
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-VPC-Flow-Log-Writer"
  })
}

module "vpc_one" {
  source                            = "terraform-aws-modules/vpc/aws"
  name                              = "${var.resource_name_prefix}-VPC-#1"
  cidr                              = var.vpc_one_cidr_block
  azs                               = data.aws_availability_zones.available.names
  private_subnets                   = [cidrsubnet(var.vpc_one_cidr_block, 4, 0)]
  public_subnets                    = [cidrsubnet(var.vpc_one_cidr_block, 4, 1)]
  enable_dns_hostnames              = true
  enable_dns_support                = true
  enable_nat_gateway                = true
  enable_flow_log                   = true
  flow_log_destination_type         = "cloud-watch-logs"
  flow_log_destination_arn          = aws_cloudwatch_log_group.vpc_one_flow_log_cw_log_group.arn
  flow_log_traffic_type             = "ALL"
  flow_log_max_aggregation_interval = 60
  flow_log_cloudwatch_iam_role_arn  = aws_iam_role.vpc_flow_log_writer_role.arn
  tags                              = var.tags
  vpc_tags = {
    Name = "${var.resource_name_prefix}-VPC-#1"
  }
  depends_on = [
    aws_cloudwatch_log_group.vpc_one_flow_log_cw_log_group,
    aws_iam_role.vpc_flow_log_writer_role
  ]
}

module "vpc_two" {
  source                            = "terraform-aws-modules/vpc/aws"
  name                              = "${var.resource_name_prefix}-VPC-#2"
  cidr                              = var.vpc_two_cidr_block
  azs                               = data.aws_availability_zones.available.names
  private_subnets                   = [cidrsubnet(var.vpc_two_cidr_block, 4, 0)]
  public_subnets                    = [cidrsubnet(var.vpc_two_cidr_block, 4, 1)]
  enable_dns_hostnames              = true
  enable_dns_support                = true
  enable_nat_gateway                = true
  enable_flow_log                   = true
  flow_log_destination_type         = "cloud-watch-logs"
  flow_log_destination_arn          = aws_cloudwatch_log_group.vpc_two_flow_log_cw_log_group.arn
  flow_log_traffic_type             = "ALL"
  flow_log_max_aggregation_interval = 60
  flow_log_cloudwatch_iam_role_arn  = aws_iam_role.vpc_flow_log_writer_role.arn
  tags                              = var.tags
  vpc_tags = {
    Name = "${var.resource_name_prefix}-VPC-#2"
  }
  depends_on = [
    aws_cloudwatch_log_group.vpc_two_flow_log_cw_log_group,
    aws_iam_role.vpc_flow_log_writer_role
  ]
}

resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id      = module.vpc_one.vpc_id
  peer_vpc_id = module.vpc_two.vpc_id
  auto_accept = true
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-Peering-Connection"
  })
}

resource "aws_route" "vpc_one_peering_route" {
  route_table_id            = module.vpc_one.private_route_table_ids[0]
  destination_cidr_block    = var.vpc_two_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_route" "vpc_two_peering_route" {
  route_table_id            = module.vpc_two.private_route_table_ids[0]
  destination_cidr_block    = var.vpc_one_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}
