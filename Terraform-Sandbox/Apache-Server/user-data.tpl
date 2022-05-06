#!/bin/bash
yum update -y
yum install httpd -y
yum install amazon-cloudwatch-agent -y

LOCAL_IP_ADDRESS=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
HOSTNAME=`curl http://169.254.169.254/latest/meta-data/hostname`
INSTANCE_TYPE=`curl http://169.254.169.254/latest/meta-data/instance-type`
INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`
START_TIME=`date '+%Y-%m-%d %H:%M:%S'`
SSM_PARAM_DETAILS=`aws ssm get-parameter --name ${ssm_parameter_name} --with-decryption`

export AWS_DEFAULT_REGION=${aws_region}

cat > /var/www/html/index.html <<HTML_EOF
<html>
<head>
<title>EC2 Apache Server</title>
</head>
<body>
<h2>EC2 Apache Server</h2>
<pre>
Hostname         = $HOSTNAME
Local IP address = $LOCAL_IP_ADDRESS
Instance type    = $INSTANCE_TYPE
Instance ID      = $INSTANCE_ID
Start time       = $START_TIME
SSM param. name  = ${ssm_parameter_name}

SSM Parameter details:
$SSM_PARAM_DETAILS

</pre>
</body>
</html>
HTML_EOF

systemctl start httpd
systemctl enable httpd
