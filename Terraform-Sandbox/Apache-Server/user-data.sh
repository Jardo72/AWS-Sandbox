#!/bin/bash
yum update -y
yum install httpd -y
yum install amazon-cloudwatch-agent -y

LOCAL_IP_ADDRESS=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
HOSTNAME=`curl http://169.254.169.254/latest/meta-data/hostname`

cat > /var/www/html/index.html <<HTML_EOF
<html>

<head>
<title>EC2 Apache Server</title>
</head>

<body>
<h2>EC2 Apache Server with CloudWatch Agent</h2>
<pre>
Hostname         = $HOSTNAME
Local IP address = $LOCAL_IP_ADDRESS
</pre>
</body>

</html>
HTML_EOF

systemctl start httpd
systemctl enable httpd
