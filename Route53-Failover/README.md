# Route53 Failover Demo

## Introduction
Demonstration of Route 53 failover routing policy. Simple deployment of two EC2 instances, each running the [L7 Load Balancing Demo](../L7-Load-Balancing) application. 

## Deployment
```
aws cloudformation create-stack --stack-name Route53-Failover-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
