provider "aws" {
  region = "eu-central-1"
}

data "aws_caller_identity" "current_account" {}

data "aws_region" "current_region" {}

data "aws_availability_zones" "availability_zones" {}

data "aws_ami" "latest_amazon_linux_ami" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

output "aws_account_id" {
  value = data.aws_caller_identity.current_account.account_id
}

output "aws_region_name" {
  value = data.aws_region.current_region.name
}

output "aws_region_description" {
  value = data.aws_region.current_region.description
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.availability_zones.names
}

output "latest_amazon_linux_ami" {
  value = data.aws_ami.latest_amazon_linux_ami.id
}
