# VPC Peering Demo

## Introduction
Simple educational/experimental CloudFormation deployment that creates a VPC peering configuration that involves:
* Two VPCs, both in the same AWS region and in the same AWS account.
* Each of the two VPCs involves a single subnet configured to assign public IP addresses to EC2 instances.
* Both VPCs are associated with in Internet Gateway, and the default route in the route table routes traffic to the Internet Gateway.
* VPC peering between the two VPCs is established. For both VPCs, the route table involves a route for the CIDR block of the other VPC that routes traffic to the VPC peering connection.
* Two EC2 instances are started, one EC2 instance in each VPC. A security group allowing ICMP traffic from the other VPC is associated with each of the two EC2 instances.
* SSH traffic from Internet is also allowed for both EC2 instances.
* Optional pair of VPC flow logs (separate flow log for each VPC).
It is possible to SSH to any of the two EC2 instances and ping the private IP address of the other EC2 instance residing in the peered VPC. As there is no SSH key pair, you have to use EC2 Instance Connect. The user data for the EC2 insatnces involves a command that installs the netcat utility, so you can use the `nc` command to try to establish TCP connections to various ports.


## Deployment
The following command can be used to deploy the setup using the AWS CLI.
```
aws cloudformation create-stack --stack-name VPC-Peering-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

The CloudFormation template involves three parameters:
* CIDR block for each of the two VPCs.
* Flag indicating whether the VPC flow logs are to be created.

The template also defines default values for all three parameters, so the parameter file can be omitted from the AWS CLI command if the defaults are acceptable. The template defines mapping for AMI IDs, so the template can be used in various AWS regions. However, the mapping only contains AMI IDs for three regions: eu-central-1, eu-west-1 and eu-west-2.

## Testing the Connectivity
It makes sense to test the following:
* The two EC2 instances shoud be able to ping each other using the private IP addresses. In the VPC flow logs, you should see accepted ICMP traffic.
* The security group for the second EC2 instance (logical ID EC2InstanceTwo) allows incoming TCP traffic to the port 80. Therefore, if you use netcat (`nc` command) on the first EC2 insatnce (logical ID EC2InstanceOne) and try to open a TCP connection to the private IP address of the second EC2 instance and to the port 80, the outcome should be "connection refused". You should also see in the VPC flow log that such a traffic has been accepted. On the other hand, attempts to open connections to other ports (e.g. 90) should lead to "connection timed out", and you should see in the VPC flow log that such a traffic has been rejected.
* The security group for the first EC2 instance (logical ID EC2InstanceOne) does not allow any TCP ports except of the port 22 (SSH). Therefore, attempts to open TCP connections from the second EC2 instance to the first EC2 instance should lead to "connection timed out", and you should see in the VPC flow log that such a traffic has been rejected.