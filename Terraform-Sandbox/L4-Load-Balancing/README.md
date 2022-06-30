# L4 Load-Balancing Demo
Terraform deployment of the [L4 Load-Balancing Demo](../../L4-Load-Balancing) application. The deployment relies on the deployment artifactory S3 bucket created by the [Common-S3-Buckets](../../Common-S3-Buckets) deployment.

The configuration is divided to the following modules:
* **vpc** module is responsible for provisioning of a VPC, its subnets, route tables, Internet Gateway and NAT Gateways.
* **nlb** module provisions an NLB, including NLB listener and target group.
* **asg** module is responsible for provisioning of an EC2 auto-scaling group. IAM instance profile for the EC2 instances as well as security group restricting network access to the EC2 instances are provisioned as well.
* **route53** module optionally provisions a Route 53 alias for the NLB.
* **cloudwatch** module creates a CloudWatch dashboard that visualizes some metrics for the EC2 auto-scaling group and the NLB.

The following snippet illustrates the values of variables used during my experiments:

```hcl
```
