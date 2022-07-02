# L7 Load-Balancing Demo
AWS CDK deployment of the [L7 Load-Balancing Demo](../../L7-Load-Balancing/) application. This deployment relies on several buckets created by the [Common-S3-Buckets](../../Common-S3-Buckets) deployment. In concrete terms:
* it assumes the application JAR file is on a common S3 bucket serving as deployment artifactory
* in case of ALB access log is enabled, it also relies on a common S3 bucket serving as store for ELB access logs