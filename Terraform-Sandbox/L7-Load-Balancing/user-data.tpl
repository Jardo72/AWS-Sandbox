#!/bin/bash
yum update -y
yum install java-1.8.0-openjdk -y
aws s3 cp s3://${deployment_artifactory_bucket}/${deployment_artifactory_prefix}/${application_jar_file} /tmp/${application_jar_file}
java -Dserver.port=${ec2_port} -jar /tmp/${application_jar_file} &
