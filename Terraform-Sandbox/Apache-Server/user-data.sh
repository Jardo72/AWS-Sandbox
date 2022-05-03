#!/bin/bash
yum update -y
yum install httpd -y
yum install amazon-cloudwatch-agent -y

systemctl start httpd
systemctl enable httpd
