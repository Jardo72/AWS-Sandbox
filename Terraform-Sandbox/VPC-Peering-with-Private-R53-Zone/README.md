# VPC Peering with Private Route 53 Hosted Zone
TODO
* Two VPCs (both in the same AWS account and the same region) with non-overlapping CIDR blocks
* Peering connection between the two VPCs, route tables configured to support traffic between the VPCs
* Two EC2 instances launched (one EC2 instance in each of the two VPCs)
* Two security groups, one for each of the two EC2 instances; ICMP traffic allowed in both directions for both EC2 instances; TODO TCP
* Private hosted zone configured in Route 53; A-records for both EC2 instances; hosted zone associated with both VPCs
