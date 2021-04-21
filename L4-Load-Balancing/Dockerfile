FROM openjdk:8-jre

COPY ./server/target/aws-sandbox-network-load-balancing-server-1.0-jar-with-dependencies.jar /usr/app/L4-LB-Demo/server.jar
WORKDIR /usr/app/L4-LB-Demo
EXPOSE 1234
ENTRYPOINT ["java", "-jar", "server.jar", "-IP-address=0.0.0.0", "-port=1234"]
