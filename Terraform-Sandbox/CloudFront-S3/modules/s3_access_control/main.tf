#
# Copyright 2024 Jaroslav Chmurny
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

resource "aws_s3_bucket_policy" "webcontent_bucket_policy" {
  bucket = var.webcontent_bucket_id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : ["s3:GetObject"],
        Effect : "Allow",
        Principal : {
          "Service" : "cloudfront.amazonaws.com"
        },
        Resource : "${var.webcontent_bucket_arn}/*"
        Condition : {
          test     = "StringEquals"
          variable = "AWS:SourceArn"
          values   = [var.cloudfront_distribution_id]
        }
      }
    ]
  })
}
