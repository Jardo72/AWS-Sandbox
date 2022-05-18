#!/bin/bash
yum update -y
yum install java-1.8.0-openjdk -y
aws s3 cp s3://${deployment_artifactory_bucket}/${deployment_artifactory_prefix}/${application_jar_file} /tmp/${application_jar_file}
java -jar /tmp/${application_jar_file} -IP-address=0.0.0.0 -TCP-port=${ec2_port} &
