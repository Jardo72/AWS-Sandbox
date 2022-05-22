# Common S3 Buckets

## Introduction
Triplet of S3 buckets (with related access policies/roles) serving as common infrastructure for the other applications in this Git repository:
* Deployment artifactory bucket for installation artifacts like JAR files, ZIP files with Python code for Lambda functions etc.
* Bucket for S3 access logs.
* Bucket for ELB access logs.

The two buckets for access logs (S3 and ELB) are configured with lifecycle rules that automatically delete files which are 14 days old. Besides the S3 buckets, IAM policy and IAM role granting access to the deployment artifactory bucket is created to support definition of IAM instance profiles. If an instance only needs access to the deployment artifactory bucket, definition of IAM instance profile can simply use the IAM role. If access to other AWS resources is needed, use the IAM policy to define an IAM role which also grants access to the other AWS resources, and use the IAM role to define an IAM instance profile.

## Deployment
The ([CloudFormation template](./cloud-formation-template.yml)) in this directory can be used to create the buckets and the related access policies/roles. The following AWS CLI command illustrates how to use the CloudFormation template to create the stack.

```
aws cloudformation create-stack --stack-name Common-S3-Buckets --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

The template involves several parameters. The [stack-params.json](./stack-params.json) file contains parameter values used during my experiments. The template exports the ARNs of IAM role and policy so you can cross-reference them from other CloudFormation stacks. Similarly, the names of the S3 buckets are exported.

Before deleting the stack, remove all files from the S3 buckets. Otherwise, the removal of the stack will fail.
