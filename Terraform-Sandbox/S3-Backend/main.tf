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

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "jardo72-terraform-state"
    key    = "terraform-sandbox/s3-backend"
    region = "eu-central-1"
  }
}

locals {
  common_tags = {
    Stack         = "S3-Backend-Demo",
    ProvisionedBy = "Terraform"
  }
}

resource "aws_iam_user" "demo_iam_user" {
  count         = 3
  name          = "TF-DEMO-USER-${count.index + 1}"
  force_destroy = true
  tags          = local.common_tags
}

resource "aws_iam_group" "demo_iam_group" {
  name = "TF-DEMO-GROUP"
}

resource "aws_iam_group_membership" "name" {
  name  = "TF-DEMO-GROUP-MEMBERSHIP"
  users = aws_iam_user.demo_iam_user[*].name
  group = aws_iam_group.demo_iam_group.name
}

resource "aws_iam_user" "extra_iam_user" {
  count         = var.create_extra_iam_user ? 1 : 0
  name          = "TF-EXTRA-USER"
  force_destroy = true
  tags          = local.common_tags
}
