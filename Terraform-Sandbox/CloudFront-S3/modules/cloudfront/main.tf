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

locals {
  origin_id = "CloudFront-S3-Demo-Origin"
}

resource "aws_cloudfront_origin_access_control" "origin_access_control" {
  name                              = "CloudFront-S3-Demo-OAC"
  description                       = "Origin Access Control for CloudFront + S3 Demo Website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = var.web_bucket_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
  }

  aliases = ["cloudfront-s3-demo.jardo72.de"]

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "CloudFront Demo Distribution"
  default_root_object = "index.html"
  tags                = var.tags

  /* TODO
  logging_config {
    include_cookies = false
    bucket          = var.access_log_bucket_name
    prefix          = "CloudFront-S3-Demo-Log"
  } */

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "vip"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
