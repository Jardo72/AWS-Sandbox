#!/bin/bash
yum update -y
yum install amazon-cloudwatch-agent -y

cat > /var/www/html/index.html <<JSON_EOF
JSON_EOF
