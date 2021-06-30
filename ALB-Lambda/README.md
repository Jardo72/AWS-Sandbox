# ALB Lambda Target

## Introduction
Simple educational/experimental Lambda function implemented in Python meant as target for Application Load Balancer. The project also involves a CloudFormation template that creates the following resources:
* Custom VPC with Internet Gateway and two public subnets, each with a default route to the Internet Gateway. The two subnets are created in distinct AZs.
* Three Lambda functions, all using the common codebase. Each of the functions is deployed with a different value of the `COLOR` environment variable.
* Internet-facing Application Load Balancer with a single listener (port 80). The listener has three listener rules, each forwarding requests to one of the three Lambda functions. The default action returns a fixed response with HTTP status 404.

## Deployment to AWS
The following AWS CLI command illustrates how to deploy the above mentioned stack using the CloudFormation template. The template expects that the Python file with the common source code for all three functions has been compressed to a ZIP file and uploaded to an S3 bucket.
```
aws cloudformation create-stack --stack-name ALB-Lambda-Sample --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

## Invocation
The following URLs illustrate how the Lambda functions can be invoked via the load balancer:
* http://<ALB-DNS-Name>/red
* http://<ALB-DNS-Name>/green
* http://<ALB-DNS-Name>/blue

Obviously, the placeholder for the DNS name of the load balancer must be replaced with the real DNS name. The DNS name is the only output in the CloudFormation template, so the DNS name can be easily obtained directly from the CloudFormation stack after the completion of the deployment.
