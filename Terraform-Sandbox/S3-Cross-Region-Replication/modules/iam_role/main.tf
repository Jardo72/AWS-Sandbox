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

resource "aws_iam_role" "replication_role" {
  name = "S3ReplicationRole"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowS3Assume",
        Action : "sts:AssumeRole",
        Principal : {
          Service : "s3.amazonaws.com"
        },
        Effect : "Allow"
      }
    ]
  })
  inline_policy {
    name = "S3ReplicationPolicy"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Sid : "SourceBucketAccess",
          Action : [
            "s3:ListBucket",
            "s3:GetReplicationConfiguration"
          ]
          Effect : "Allow"
          Resource : var.source_bucket_arn
        },
        {
          Sid : "SourceObjectAccess",
          Action : [
            "s3:GetObjectVersion",
            "s3:GetObjectVersionAcl",
            "s3:GetObjectVersionTagging"
          ]
          Effect : "Allow"
          Resource : "${var.source_bucket_arn}/*"
        },
        {
          Sid : "DestinationObjectAccess",
          Action : [
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags"
          ]
          Effect : "Allow"
          Resource : "${var.destination_bucket_arn}/*"
        }
      ]
    })
  }
}
