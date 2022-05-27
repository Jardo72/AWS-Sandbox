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
            "Action": [
                "ssm:DescribeParameters",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:PutParameter",
                "ssm:DeleteParameter",
                "ssm:DeleteParameters"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": "eu-central-1"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "AllowLimitedEC2InEUCentral1"
        }
    ]
}
```
