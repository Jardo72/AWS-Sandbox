# L7 Load-Balancing Demo

## Introduction
- SpringBoot application exposing REST API
- information collected by the service
- illustration of L7 load balancing that can be used for experiments with AWS, Docker or Kubernetes
- plain HTTP (i.e. not HTTPS) - no need for security, ease of use is desired


## Source Code Organization and Building
- Maven project
- runnable fat JAR 

In order to build the applications, just navigate to the root directory of the project and execute the following command:
```
mvn clean package
```


## How to Start the Service
- application.properties
- bind to 0.0.0.0 (i.e. all network interfaces), TCP port 80
```
java -jar .\target\aws-sandbox-application-load-balancing-server-1.0.jar
```


## How to Send Requests to the Service
- GET method
- URL: http://localhost:8001/api/system-info
- Postman screenshot might make sense

## How to Deploy the Service to AWS

### EC2
- via AWS Console
- via AWS CLI
- CloudFormation

```
# install Java on the EC2 instance
yum install java-1.8.0-openjdk -y
```

```
# copy the service to the EC2 instance
scp -i <private-key-file> ./target/aws-sandbox-network-load-balancing-1.0.jar ec2-user@<instance-ip-address>:/home/ec2-user
```

### ECS
