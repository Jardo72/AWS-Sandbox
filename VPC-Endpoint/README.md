# VPC Endpoint Demo

## Introduction
Demonstration of VPC gateway endpoints (S3) and advanced IAM policies with conditions.

Two VPCs:
* 
*

Three S3 buckets with blocked public access:
* One without any bucket policy (i.e. access is not restricted to any VPC or VPC endpoint).
* One with a bucket policy restricting access so that four operations (GetObject, PutObject, DeleteObject and ListBucket) are only allowed from the green VPC.
* One with a bucket policy restricting access so that four operations (GetObject, PutObject, DeleteObject and ListBucket) are only allowed via the VPC endpoint created in the green VPC.

In addition, the setup also involves two EC2 instances - one in the green VPC, one in the red VPC. Both EC2 instances 

## Deployment
The following command can be used to deploy the setup using the AWS CLI.
```
aws cloudformation create-stack --stack-name VPC-Endpoint-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
