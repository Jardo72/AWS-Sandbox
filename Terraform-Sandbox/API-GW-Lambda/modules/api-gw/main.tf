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

locals {
  runtime = "python3.8"
  timeout = 10
}

data "archive_file" "api_gw_authorizer_function_archive" {
  type        = "zip"
  source_file = "${path.module}/api-gw-authorizer.py"
  output_path = "${path.module}/api-gw-authorizer.zip"
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = "${var.resource_name_prefix}-REST-API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  body = templatefile("${path.module}/api-definition.yml", {
    aws_region                      = var.aws_region,
    read_ssm_parameter_function_arn = var.read_ssm_parameter_function_arn,
    kms_encryption_function_arn     = var.kms_encryption_function_arn,
    kms_decryption_function_arn     = var.kms_decryption_function_arn
  })
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = "sandbox"
}

resource "aws_iam_role" "api_gw_authorizer_execution_role" {
  name = "${var.resource_name_prefix}-APIGW-Authorizer-Execution-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaToAssumeRole"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSLambdaExecute"
  ]
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-APIGW-Authoririzer-Execution-Role"
  })
}


resource "aws_lambda_function" "api_gw_authorizer_function" {
  function_name    = "${var.resource_name_prefix}-APIGWAuthorizer-Function"
  filename         = data.archive_file.api_gw_authorizer_function_archive.output_path
  source_code_hash = data.archive_file.api_gw_authorizer_function_archive.output_base64sha256
  handler          = "api-gw-authorizer.main"
  runtime          = local.runtime
  timeout          = local.timeout
  role             = aws_iam_role.api_gw_authorizer_execution_role.arn
  environment {
    variables = {
      API_GW_ARN = aws_api_gateway_rest_api.rest_api.arn
    }
  }
}

resource "aws_iam_role" "api_gw_authorizer_invocation_role" {
  name = "${var.resource_name_prefix}-APIGW-Authorizer-Invocation-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAPIGatewayToAssumeRole"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "my_inline_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["lambda:InvokeFunction"]
          Effect   = "Allow"
          Resource = "${aws_lambda_function.api_gw_authorizer_function.arn}"
        }
      ]
    })
  }
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-APIGW-Authoririzer-Invocation-Role"
  })
}

resource "aws_api_gateway_authorizer" "api_gw_authorizer" {
  name                   = "demo"
  rest_api_id            = aws_api_gateway_rest_api.rest_api.id
  authorizer_uri         = aws_lambda_function.api_gw_authorizer_function.invoke_arn
  authorizer_credentials = aws_iam_role.api_gw_authorizer_invocation_role.arn
  identity_source        = "method.request.header.Authorization"
  type                   = "REQUEST"
}
