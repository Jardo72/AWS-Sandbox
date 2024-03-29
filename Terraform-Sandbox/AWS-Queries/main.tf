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
  region = "eu-central-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east"
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

data "aws_ami" "latest_amazon_linux_ami_us_east" {
  provider    = aws.us_east
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_s3_bucket" "deplyment_artifactory_bucket" {
  bucket = "jardo72-deplyment-artifactory"
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

output "latest_amazon_linux_ami_us_east" {
  value = data.aws_ami.latest_amazon_linux_ami_us_east.id
}

output "number_of_az_in_region" {
  value = "There are ${length(data.aws_availability_zones.availability_zones.names)} AZ(s) in region '${data.aws_region.current_region.name}'"
}

output "names_of_azs_as_csv" {
  value = join(", ", data.aws_availability_zones.availability_zones.names)
}

output "deplyment_artifactory_bucket_arn" {
  value = data.aws_s3_bucket.deplyment_artifactory_bucket.arn
}