# L4 Load-Balancing Demo

## Introduction
- pair of console Java applications
- dummy TCP server
- dummy TCP client
- information collected by the server
- client connects and repeatedly retrieves the info from the server
- both client and server write trace to stdout
- illusration of L4 load balancing that can be used for experiments with AWS, Docker or Kubernetes

## Source Code Organization and Building

- multimodule Maven project
- 3 modules (commons, client and server)
- 2 runnable fat JARs (one for client, one for server)

In order to build the applications, just navigate to the root directory of the project and execute the following command:
```
mvn clean package
```
The command above will automatically build all three modules comprising the project. After successful build, there will be two runnable fat JAR files, one the client and one for the  server.

## How to Start the Server and the Client

```
# start the server
java -jar ./server/target/aws-sandbox-network-load-balancing-server-1.0-jar-with-dependencies.jar -IP-address=<IP address> -port=<TCP port>
```

```
# start the client
java -jar .\client\target\aws-sandbox-network-load-balancing-client-1.0-jar-with-dependencies.jar -IP-address=<IP address> -port=<TCP port> -request-count=<number-of-requests-to-be-sent> break-between-requests-sec=<duration-seconds>
```

## How to Deploy the Server to AWS

### EC2

### ECS
