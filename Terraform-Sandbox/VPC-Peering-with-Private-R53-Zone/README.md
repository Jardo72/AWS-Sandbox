# VPC Peering with Private Route 53 Hosted Zone

## Introduction
Terraform configuration demonstrating:
* VPC peering
* Route 53 private hosted zones
* VPC flow logs

The configuration involves the following resources:
* Two VPCs (both in the same AWS account and the same AWS region) with non-overlapping CIDR blocks.
* Peering connection between the two VPCs, plus route tables configured to support traffic between the two VPCs.
* Two EC2 instances (one EC2 instance launched in each of the two VPCs). The EC2 user data script installs the ncat (aka nc) utility on both instances so it can be used to test the connectivity.
* Two security groups, one for each of the two EC2 instances. ICMP traffic is allowed in both directions for both EC2 instances. TCP is only allowed from the instance #1 to the instance #2 (the other direction is blocked completely). The security group for the instance #1 allows any outbound TCP traffic (any port), the security group for the instance #2 only allows inbound traffic to the ports between 80 and 100. In other words, the setup allows to test various TCP scenarios (accepted/rejected traffic, rejected outbound/inbound traffic etc.) in combination with VPC flow logs.
* Private hosted zone configured in Route 53. A-records for both EC2 instances (one record for each of the two EC2 instances). The hosted zone is associated with both VPCs, so when testing the conncectivity, you can use both private IP addresses of the EC2 instances and they custom DNS names generated and assigned by the Terraform configuration (not by AWS).
* VPC flow log for both VPCs (separate VPC flow log for each VPC). The flow logs are written to CloudWatch Logs - a separate log group is created for each of the two VPCs.

The following snippet illustrates the values of Terraform variables used during my experiments:
```hcl
```

# Connectivity Testing & VPC Flow Logs

```
```
