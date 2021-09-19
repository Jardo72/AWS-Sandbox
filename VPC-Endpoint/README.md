# VPC Endpoint Demo

## Introduction

## Deployment
The following command can be used to deploy the setup using the AWS CLI.
```
aws cloudformation create-stack --stack-name VPC-Endpoint-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
