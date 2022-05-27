# Terraform Cloud Demo

## Introduction
Simple Tarraform configuration supposed to be applied by Tarraform Cloud using CLI. The only resources provision in AWS are few parameters in the SSM Parameter Store.

## AWS IAM Permission Boundary for IAM User
In order to minimize the permissions granted to the AWS IAM user whose access key will be provided to Terraform Cloud, I use an IAM user with the following permissions boundary:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowLimitedSSMInEUCentral1",
            "Action": [
                "ssm:DescribeParameters",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:PutParameter",
                "ssm:DeleteParameter",
                "ssm:DeleteParameters",
                "ssm:ListTagsForResource",
                "ssm:AddTagsToResource"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": "eu-central-1"
                }
            },
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
```
This limits the access to just few SSM Parameter Store operations, and those operations can only be performed in the EU Central-1 AWS region.

## Values for the Terraform Variables
The following snippet illustrates possible values for the Tarraform variables. These have to be configured in Terraform Cloud.

```hcl
standalone_parameter_value = "Standalone parameter value"

parameter_definition = {
  "PARAM-01" = {
    description = "Dummy description",
    value       = "Dummy value from Terraform variable",
    type        = "String"
  },
  "PARAM-02" = {
    description = "Useless description",
    value       = "Useless value from Terraform variable",
    type        = "String"
  },
  "PARAM-03" = {
    description = "Purposeless description",
    value       = "Purposeless value from Terraform variable",
    type        = "String"
  }
}
```
