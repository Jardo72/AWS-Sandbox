# L4 Load-Balancing Demo

## Introduction
L4 Load-Balancing Demo is an experimantal/educational project meant as illustration of L4 (aka network) load balancing in combination with AWS, Docker, Kubernetes etc. The project actually involves two applications:
- simple server which opens a TCP socket in listening mode, accepts incoming connections from clients and handles requests from clients
- simple client which connects to the server, sends the specified number of requests to the server and writes the responses from the server to stdout

Both server and client are simple Java console applications based on Java SE, without any additional dependencies on any 3rd party frameworks or libraries. The client connects to the server via plain TCP (i.e. no SSL/TLS). 

The server involves two counters - one collecting the number of accepted connections, and the other collecting the number of handled requests. The first counter is incremented whenever a new connection from a client is accepted. The second counter is accepted whenever a request from a client is handled. When a request from a client is handled by a server, the server sends the following information to the client:
- the current values of both above mentioned counters
- information about the server process (the hostname of the host where it is running, the user under which it is running, the start time of the server process)
- information about both endpoints of the TCP connection (server IP address + TCP port, client IP address + TCP port)

Single client opens a single connection to the server, sends the specified number of requests with the given periodicity, prints the responses from the server to stdout, and terminates. Each client generates a random UUID which serves as its unique client ID. This information is sent to the server as part of each request.

## Source Code Organization and Building
The project is organized as multi-module Maven project consisting of 3 modules:
- `commons` is a simple Java library providing functionalities common to both the server and the client. The other two modules have a dependency on this module.
- `server` is an application serving as the above described server.
- `client` is an application serving as the above described client.

In order to build both applications, just navigate to the root directory of the project and execute the following command (assumed Maven is installed and properly configured):
```
mvn clean package
```

The command above will automatically build all three modules comprising the project. After a successful build, there will be two JAR files for the client, and two JAR files for the server. Two of the four JAR files, one for the client and one for the server, are runnable JAR files which can be immediately used to start the server and the client. In concrete terms, the runnable JAR files are:
- `./server/target/aws-sandbox-network-load-balancing-server-1.0-jar-with-dependencies.jar` for the server
- `./client/target/aws-sandbox-network-load-balancing-client-1.0-jar-with-dependencies.jar` for the client


## How to Start the Server and the Client
The following command illustrates how to start the server. Obviously, you have to specify the IP address of the network interface the server has to bind to, plus the TCP port the server has to bind to. You can use the value 0.0.0.0 if you want the server to bind to all available network interfaces.
```
# start the server
java -jar ./server/target/aws-sandbox-network-load-balancing-server-1.0-jar-with-dependencies.jar -IP-address=<IP address> -port=<TCP port>
```

The following command illustrates how to start the client. You have to specify the IP address where the server is reachable, plus the TCP port. In addition, you also have to specify how many requests the client has to send to the server, plus the duration of the break between two consecutive requests in seconds.
```
# start the client
java -jar ./client/target/aws-sandbox-network-load-balancing-client-1.0-jar-with-dependencies.jar -IP-address=<IP address> -port=<TCP port> -request-count=<number-of-requests-to-be-sent> break-between-requests-sec=<break-duration-seconds>
```

## How to Deploy the Server to AWS

### Network Load Balancer + EC2 Auto Scaling Group
```
aws cloudformation create-stack --stack-name L4-LB-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --on-failure ROLLBACK
```
