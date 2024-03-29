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

resource "aws_s3_bucket" "webcontent_bucket" {
  bucket = var.webcontent_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "webcontent_public_access_config" {
  bucket                  = aws_s3_bucket.webcontent_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "start_page" {
  bucket       = var.webcontent_bucket_name
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/index.html")
  depends_on   = [aws_s3_bucket.webcontent_bucket]
}

resource "aws_s3_object" "diagram" {
  bucket       = var.webcontent_bucket_name
  key          = "diagram.png"
  source       = "${path.root}/diagram.png"
  content_type = "image/png"
  etag         = filemd5("${path.root}/diagram.png")
  depends_on   = [aws_s3_bucket.webcontent_bucket]
}
