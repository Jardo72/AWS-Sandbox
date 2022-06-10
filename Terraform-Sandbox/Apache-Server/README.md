# Terraform Deployment of Apache Web Server
Simple Terraform configuration which provisions the following set of resources:
- random password which is also stored as secure string in the SSM parameter store
- VPC with Internet gateway, single public subnet and route table
- single EC2 instance with an elastic IP address attached
- security group protecting the EC2 instance, allowing ingress HTTP(S) traffic (ports 80 443) from anywhere

The EC2 instance is running the Apache web server, which is installed and started via EC2 user data. During the bootstrapping, index.html file is generated. It provides various information about the EC2 instance, plus the details of the SSM parameter storing the generated radnom password (including the decrypted value of the secure string). The IAM role used as instance profile has the AWS managed policy `arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM` attached, so you can use the Systems Manager/Session Manager to connect to the EC2 instance. The EC2 instance is configured so that a modification of the user data leads to replacement of the EC2 instance. In order to minimize the downtime during the replacement, the lifecycle of the EC2 instance is configured so that the replacement EC2 instance is started before the original EC2 instance is terminated. Becauce of the elastic IP address, there is a constant IP address which does not change in case of replacement.

The Web server has no TLS certificate, and it is not configured to listen on TCP port 443. Therefore, only plain HTTP connections are possible (no HTTPS). The security group allows TCP port 80 as well as TCP port 443 to illustrate Terraform dynamic block feature.

The user data script for the EC2 instance is generated using the `templatefile` function. As outlined above, when you modify the template file and apply the Terraform configuration again, the EC2 instance will be replaced by a new one reflecting the modified user data. In other words, the index.html file for new EC2 instance will reflect the modified user data.

The Terraform configuration also involves a null_resource with local-exec provisioner which is waiting until the EC2 status checks pass. The local-exec provisioner uses the `aws ec2 wait instance-status-ok` AWS CLI command. Therefore, an attempt to apply this configuration on a host where AWS CLI is not installed will fail. Anyway, this is a nice demonstration of the `local-exec` provisioner.
