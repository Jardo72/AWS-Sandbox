# Route 53 Failover Demo

## Introduction
Demonstration of Route 53 failover routing policy. Simple deployment of two EC2 instances, each running the [L7 Load Balancing Demo](../L7-Load-Balancing) application. Route 53 health check and a pair of failover DNS records (type A) with identical DNS name is configured. The DNS records refer to the IP addresses of the EC2 instances. The health check is of type HTTP, and it monitors the `GET /api/health-check` API endpoint of the EC2 instance designated as primary. Initially, the DNS name translates to the IP address of the primary EC2 instance. If the health check will lead to two consecutive failures (which can be controlled by other API endpoints provided by the [L7 Load Balancing Demo](../L7-Load-Balancing) application), Route 53 will automatically associate the DNS name with the secondary EC2 instance.

## Deployment
The project involves parametrized CloudFormation template ([cloud-formation-template.yml](./cloud-formation-template.yml)) that will automatically create the above described setup. The following AWS CLI command illustrates how to use the CloudFormation template to create the stack.
```
aws cloudformation create-stack --stack-name Route53-Failover-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

The template involves several parameters. The [stack-params.json](./stack-params.json) file contains parameter values used during my experiments. The template expects the [L7 Load Balancing Demo](../L7-Load-Balancing) application JAR file to be available on an S3 bucket whose name must be specified as one of the template parameters.
