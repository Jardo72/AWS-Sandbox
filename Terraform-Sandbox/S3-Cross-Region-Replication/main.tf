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

provider "aws" {
  alias  = "source_bucket_region"
  region = var.source_bucket_details.aws_region
}

provider "aws" {
  alias  = "destination_bucket_region"
  region = var.destination_bucket_details.aws_region
}

module "source_s3_bucket" {
  source = "./modules/s3_bucket"
  providers = {
    aws = aws.source_bucket_region
  }
  bucket_name = var.source_bucket_details.bucket_name
  tags        = var.tags
}

module "destination_s3_bucket" {
  source = "./modules/s3_bucket"
  providers = {
    aws = aws.destination_bucket_region
  }
  bucket_name = var.destination_bucket_details.bucket_name
  tags        = var.tags
}

module "iam_role" {
  source                 = "./modules/iam_role"
  source_bucket_arn      = module.source_s3_bucket.bucket_details.arn
  destination_bucket_arn = module.destination_s3_bucket.bucket_details.arn
  tags                   = var.tags
}

module "s3_replication" {
  source                 = "./modules/s3_replication"
  source_bucket_name     = module.source_s3_bucket.bucket_details.name
  destination_bucket_arn = module.destination_s3_bucket.bucket_details.arn
  role_arn               = module.iam_role.replication_role_details.arn
  depends_on = [
    module.source_s3_bucket,
    module.destination_s3_bucket
  ]
}
