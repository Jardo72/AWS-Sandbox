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

```
java -jar .\target\aws-sandbox-network-load-balancing-1.0.jar
```


## How to Send Requests to the Service

## How to Deploy the Service to AWS

### EC2

### ECS
