FROM openjdk:8-jre

COPY ./target/aws-sandbox-application-load-balancing-server-1.0.jar /usr/app/L7-LB-Demo/server.jar
WORKDIR /usr/app/L7-LB-Demo
EXPOSE 80
ENTRYPOINT ["java", "-jar", "server.jar"]
