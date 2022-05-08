locals {
  aws_region         = "eu-central-1"
  ssm_parameter_name = "/terraform-sandbox/apache-server/dummy-password"
  common_tags = {
    Name          = "Apache-Demo",
    ProvisionedBy = "Terraform"
  }
}

provider "aws" {
  region = local.aws_region
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
  name        = local.ssm_parameter_name
  value       = random_password.dummy_password.result
  tags        = local.common_tags
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags                 = local.common_tags
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.common_tags
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags                    = local.common_tags
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = local.common_tags
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
    for_each = ["80", "443"]
    content {
      protocol         = "tcp"
      from_port        = ingress.value
      to_port          = ingress.value
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Allow inbound HTTP(S)"
    }
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.common_tags
}

resource "aws_eip" "web_server_elastic_ip" {
  instance = aws_instance.web_server.id
  vpc      = true
  tags     = local.common_tags
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
          Resource : format("arn:aws:ssm:%s:%s:parameter%s", local.aws_region, data.aws_caller_identity.current_account.account_id, local.ssm_parameter_name)
        }
      ]
    })
  }

  # needed in order to be able to connect to the instance via the Session Manager
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  ]

  tags = local.common_tags
}

resource "aws_iam_instance_profile" "ssm_parameter_reader_profile" {
  name = "SSMParameterReaderProfile"
  role = aws_iam_role.ssm_parameter_reader_role.name
  tags = local.common_tags
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.latest_amazon_linux_ami.id
  instance_type          = "t2.nano"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_server_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_parameter_reader_profile.name
  user_data = templatefile("user-data.tpl", {
    aws_region         = local.aws_region
    ssm_parameter_name = local.ssm_parameter_name
  })
  tags = local.common_tags
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_ssm_parameter.dummy_password]
}

output "aws_account_id" {
  value = data.aws_caller_identity.current_account.account_id
}

output "latest_amazon_linux_ami" {
  value = data.aws_ami.latest_amazon_linux_ami.id
}

output "web_server_elastic_ip" {
  value = aws_eip.web_server_elastic_ip.public_ip
}

output "web_server_elastic_dns_name" {
  value = aws_eip.web_server_elastic_ip.public_dns
}
