# VPC Peering Demo

## Introduction
Simple educational/experimental CloudFormation deployment that creates a VPC peering configuration that involves:
* Two VPCs, both in the same AWS region and in the same AWS account.
* Each of the two VPCs involves a single subnet configured to assign public IP addresses to EC2 instances.
* Both VPCs are associated with in Internet Gateway, and the default route in the route table routes traffic to the Internet Gateway.
* VPC peering between the two VPCs is established. For both VPCs, the route table involves a route for the CIDR block of the other VPC that routes traffic to the VPC peering connection.
* Two EC2 instances are started, one EC2 instance in each VPC. A security group allowing ICMP traffic from the other VPC is associated with each of the two EC2 instances.
* SSH traffic from Internet is also allowed for both EC2 instances.
It is possible to SSH to any of the two EC2 instances and ping the private IP address of the other EC2 instance residing in the peered VPC.

## Deployment
The following command can be used to deploy the setup using the AWS CLI.
```
aws cloudformation create-stack --stack-name VPC-Peering-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --on-failure ROLLBACK
```

The CloudFormation template involves four parameters:
* CIDR block for each of the two VPCs.
* CIDR block for the two public subnets (one in each VPC).

The template also defines default values for all four parameters, so the parameter file can be omitted from the AWS CLI command if the defaults are acceptable. The template defines mapping for AMI IDs, so the template can be used in various AWS regions. However, the mapping only contains AMI IDs for three regions: eu-central-1, eu-west-1 and eu-west-2.
