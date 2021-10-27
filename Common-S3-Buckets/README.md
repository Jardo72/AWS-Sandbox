# Common S3 Buckets

## Introduction
Triplet of S3 buckets (with related access policies/roles) serving as common infrastructure for the other applications in this Git repository:
* Deployment artifactory bucket for installation artifacts like JAR files, ZIP files with Python code for Lambda functions etc.
* Bucket for S3 access logs.
* Bucket for ELB access logs.

## Deployment
The ([CloudFormation template](./cloud-formation-template.yml)) in this directory can be used to create the buckets and the related access policies/roles. The following AWS CLI command illustrates how to use the CloudFormation template to create the stack.

```
aws cloudformation create-stack --stack-name Common-S3-Buckets --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

The template involves several parameters. The [stack-params.json](./stack-params.json) file contains parameter values used during my experiments.
