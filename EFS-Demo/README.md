# EFS Demo

## Introduction
Simple demonstration of EFS with two EC2 instances which automatically mount the EFS file system to `/mnt/efs`.

## Deployment
The project involves a CloudFormation template [cloud-formation-template.yml](./cloud-formation-template.yml) which simplifies the deployment. The CloudFormation template creates the entire stack:
* VPC with subnets, route table, security groups etc.
* the EFS file system with a mount target in each subnet
* two EC2 instances that automatically mount the EFS file share via the user data initialization script

The following AWS CLI command illustrates how to use the CloudFormation template to create the stack.
```
aws cloudformation create-stack --stack-name EFS-Demo --template-body file://cloud-formation-template.yml --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
