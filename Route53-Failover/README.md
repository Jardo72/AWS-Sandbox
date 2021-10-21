# Route53 Failover Demo

## Introduction

## Deployment
```
aws cloudformation create-stack --stack-name Route53-Failover-LB-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
