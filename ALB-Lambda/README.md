# ALB Lambda Target

## Introduction
Simple educational/experimental Lambda function implemented in Python meant as target for Application Load Balancer. The project also involves a CloudFormation template that creates the following resources:
* Application Load Balancer
* Three Lambda functions, all using the common codebase. Each of the functions is deployed with a different value of the `COLOR` environment variable.

## Deployment to AWS
```
aws cloudformation create-stack --stack-name ALB-Lambda-Sample --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

## Invocation
