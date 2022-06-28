# L7 Load-Balancing Demo
Terraform deployment of the [L7 Load-Balancing Demo](../../L7-Load-Balancing) application. This deployment relies on several buckets created by the [Common-S3-Buckets](../../Common-S3-Buckets) deployment. In concrete terms:
* it assumes the application JAR file is on a common S3 bucket serving as deployment artifactory
* in case of ALB access log is enabled, it also relies on a common S3 bucket serving as store for ELB access logs

The configuration is divided to the following modules:
* **vpc** module is responsible for provisioning of a VPC, its subnets, route table and Internet Gateway.
* **alb** module provisions an ALB, including ALB listener and target group. Security group restricting network access to the ALB is also provisioned by this module. Optionally, ALB access log can also be enabled/configured.
* **asg** module is responsible for provisioning of an EC2 auto-scaling group with target-tracking policy which adapts the number of EC2 instances based on the aggregate CPU utilization for the entire auto-scaling group. IAM instance profile for the EC2 instances as well as security group restricting network access to the EC2 instances are provisioned as well.
* **route53** module optionally provisions a Route 53 alias for the ALB.
* **cloudwatch** module creates a CloudWatch dashboard that visualizes some metrics like CPU utilization for the EC2 auto-scaling group.
