How to Start the Server
java -jar .\server\target\aws-sandbox-network-load-balancing-server-1.0-jar-with-dependencies.jar -IP-address=<IP address> -port=<TCP port>

How to Start the Client
java -jar .\client\target\aws-sandbox-network-load-balancing-client-1.0-jar-with-dependencies.jar -IP-address=127.0.0.1 -port=1234 -requestCount=5 break-between-requests-sec=5
