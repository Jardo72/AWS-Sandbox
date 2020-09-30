# L7 Load-Balancing Demo

## Introduction
L7 Load-Balancing Demo is an experimantal/educational application meant as illustration of L7 (aka application) load balancing in combination with AWS, Docker, Kubernetes etc. It is a Java application based on the SpringBoot framework which exposes a single REST API endpoint providing access to:
- the number of REST requests handled so far by the application (there is a counter which is incremented whenever a REST request is handled)
- information about the server process and the host where it is running (hostname, username, number of processors available)
- information about the connection used to deliver the current request (e.g. IP address/TCP port for both client and server)

As the application does not deal with any sensitive data, there is no need for security. In addition, I wanted to make the application as simple and cheap as possible. Therefore, the REST API exposed by the application is accessible via plain HTTP (i.e. not via HTTPS).


## Source Code Organization and Building
The application is organized as a simple Maven project. In order to build the applications, just navigate to the root directory of the project and execute the following command (assumed Maven is installed and properly configured):

```
mvn clean package
```

The command above builds a fat runnable JAR file with all dependencies (including Spring and embedded HTTP server) which can be immediately used to start the application. The name of the JAR file is `aws-sandbox-application-load-balancing-server-1.0.jar`, and it resides in the `target` directory.

## How to Start the Service
The fat runnable JAR file mentioned in the previous section also involves `application.properties` file allowing to configure the application. The default configuration binds the embedded HTTP server to all available network interfaces (i.e. 0.0.0.0), so in the vast majority of cases, there is no need to change this. The default configuration binds the embedded HTTP server to the TCP port 80, which should also be OK for most use cases. The following command illustrates how to start the application with the default settings.

```
java -jar ./target/aws-sandbox-application-load-balancing-server-1.0.jar
```

The above mentioned default settings can be overwritten by Java system properties when starting the application. The following command illustrates how to bind the HTTP server to the network interface with the IP address 192.168.0.10 and to the TCP port 8080.

```
java -Dserver.address=192.168.0.10 -Dserver.port=8080 -jar ./target/aws-sandbox-application-load-balancing-server-1.0.jar
```

## How to Send Requests to the Service
The one and only REST API endpoint exposed by the application is accesible via the HTTP GET method. The general pattern for the URL is `http://<host-name>:<port>/api/system-info`. If the application is listening on port 80 (which is the default configuration), the port can be omitted. For instance, if the application is running on a host with the IP address 192.168.0.10, and the port 80 is used, the URL will be `http://192.168.0.10/api/system-info`.

TODO:
- Postman screenshot might make sense

## How to Deploy the Application to AWS

### EC2
TODO
- parametrized CloudFormation template that will create everything from VPC up to ASG + ELB

### ECS
TODO

### EKS
TODO
