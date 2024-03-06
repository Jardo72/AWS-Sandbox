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

data "archive_file" "kms_function_archive" {
  type        = "zip"
  source_file = "${path.module}/kms-encryption.py"
  output_path = "${path.module}/kms-encryption.zip"
}

data "archive_file" "ssm_parameter_function_archive" {
  type        = "zip"
  source_file = "${path.module}/read-ssm-parameter.py"
  output_path = "${path.module}/read-ssm-parameter.zip"
}

data "archive_file" "api_gw_authorizer_function_archive" {
  type        = "zip"
  source_file = "${path.module}/api-gw-authorizer.py"
  output_path = "${path.module}/api-gw-authorizer.zip"
}

resource "aws_iam_policy" "cloudwatch_logs_access_policy" {
  name = "${var.resource_name_prefix}-CloudWatchLogs-AccessPolicy"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowCloudWatchLogsAccess",
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_policy" "ssm_parameters_access_policy" {
  name = "${var.resource_name_prefix}-SSMParameters-AccessPolicy"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowSSMParamReadAccess",
        Effect : "Allow",
        Action : [
          "ssm:GetParameter"
        ],
        Resource : "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter${var.ssm_parameter_name_prefix}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "kms_operations_access_policy" {
  name = "${var.resource_name_prefix}-KMSOperations-AccessPolicy"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowKMSEncryptionDecryption",
        Effect : "Allow",
        Action : [
          "kms:encrypt",
          "kms:decrypt"
        ]
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role" "ssm_parameters_reader_role" {
  name = "${var.resource_name_prefix}-SSMParametersReader-Role"
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
    aws_iam_policy.cloudwatch_logs_access_policy.arn,
    aws_iam_policy.ssm_parameters_access_policy.arn
  ]
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-SSM-Parameters-Reader-Role"
  })
}

resource "aws_iam_role" "kms_encryption_role" {
  name = "${var.resource_name_prefix}-KMSEncryption-Role"
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
    aws_iam_policy.cloudwatch_logs_access_policy.arn,
    aws_iam_policy.kms_operations_access_policy.arn
  ]
  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-KMS-Encryption-Role"
  })
}

resource "aws_lambda_function" "read_ssm_parameter_function" {
  function_name    = "${var.resource_name_prefix}-SSMParameterReader-Function"
  filename         = data.archive_file.ssm_parameter_function_archive.output_path
  source_code_hash = data.archive_file.ssm_parameter_function_archive.output_base64sha256
  handler          = "read-ssm-parameter.main"
  runtime          = local.runtime
  timeout          = local.timeout
  role             = aws_iam_role.ssm_parameters_reader_role.arn
}

resource "aws_lambda_function" "kms_encryption_function" {
  function_name    = "${var.resource_name_prefix}-KMSDecryption-Function"
  filename         = data.archive_file.kms_function_archive.output_path
  source_code_hash = data.archive_file.kms_function_archive.output_base64sha256
  handler          = "kms-encryption.encrypt_main"
  runtime          = local.runtime
  timeout          = local.timeout
  role             = aws_iam_role.kms_encryption_role.arn
}

resource "aws_lambda_function" "kms_decryption_function" {
  function_name    = "${var.resource_name_prefix}-KMSEncryption-Function"
  filename         = data.archive_file.kms_function_archive.output_path
  source_code_hash = data.archive_file.kms_function_archive.output_base64sha256
  handler          = "kms-encryption.decrypt_main"
  runtime          = local.runtime
  timeout          = local.timeout
  role             = aws_iam_role.kms_encryption_role.arn
}

resource "aws_lambda_function" "api_gw_authorizer_function" {
  function_name    = "${var.resource_name_prefix}-APIGWAuthorizer-Function"
  filename         = data.archive_file.api_gw_authorizer_function_archive.output_path
  source_code_hash = data.archive_file.api_gw_authorizer_function_archive.output_base64sha256
  handler          = "api-gw-authorizer.main"
  runtime          = local.runtime
  timeout          = local.timeout
  role             = aws_iam_role.kms_encryption_role.arn
  environment {
    variables = {
      DUMMY_ARN = "arn:aws:lambda:eu-central-1:467504711004:function:API-GW-Lambda-Demo-APIGWAuthorizer-Function"
    }
  }
}

resource "aws_lambda_permission" "read_ssm_parameter_function_permission" {
  statement_id  = "AllowInvocationToAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read_ssm_parameter_function.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "kms_encryption_function_permission" {
  statement_id  = "AllowInvocationToAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kms_encryption_function.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "kms_decryption_function_permission" {
  statement_id  = "AllowInvocationToAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kms_decryption_function.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "api_gw_authorizer_function_permission" {
  statement_id  = "AllowInvocationToAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_gw_authorizer_function.function_name
  principal     = "apigateway.amazonaws.com"
}
