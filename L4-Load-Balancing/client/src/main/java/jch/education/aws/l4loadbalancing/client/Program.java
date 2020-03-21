/*
 * Copyright 2019 Jaroslav Chmurny
 *
 * This file is part of AWS Sandbox.
 *
 * AWS Sandbox is free software developed for educational purposes. It
 * is licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package jch.education.aws.l4loadbalancing.client;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import jch.education.aws.l4loadbalancing.commons.ClientInfo;
import jch.education.aws.l4loadbalancing.commons.CommandLineArguments;
import jch.education.aws.l4loadbalancing.commons.ProcessInfo;
import jch.education.aws.l4loadbalancing.commons.ServerInfo;
import jch.education.aws.l4loadbalancing.commons.StatisticsInfo;
import jch.education.aws.l4loadbalancing.commons.Timing;

public class Program {
    
    public static void main(String[] args) throws IOException {
        System.out.println("Hello world!!! My name is Client.");
        
        final String ipAddress = CommandLineArguments.extractStringValue(args, "IP-address");
        final int port = CommandLineArguments.extractIntValue(args, "port", 1234);
        final int requestCount = CommandLineArguments.extractIntValue(args, "request-count", 1);
        final int breakBetweenRequestsSec = CommandLineArguments.extractIntValue(args, "", 0);
        
        final String clientId = UUID.randomUUID().toString();
        final ClientSocket clientSocket = new ClientSocket(ipAddress, port, 5);
        for (int i = 1; i <= requestCount; i++) {
            ClientInfo clientInfo = new ClientInfo(clientId, i, requestCount);
            clientSocket.writeClientInfo(clientInfo);

            ServerInfo serverInfo = clientSocket.readServerInfo();
            print(serverInfo);
            Timing.sleep(breakBetweenRequestsSec, TimeUnit.SECONDS);
        }
    }

    private static void print(ClientInfo clientInfo) {
        System.out.println();

        System.out.printf("Client ID: %s%n", clientInfo.getClientId());
        System.out.printf("Request #: %d%n", clientInfo.getRequestNumber());
    }

    private static void print(ServerInfo serverInfo) {
        System.out.println();
        System.out.println();

        System.out.println("Server process information");
        ProcessInfo processInfo = serverInfo.getProcessInfo();
        System.out.printf("Hostname:   %s%n", processInfo.getHostname());
        System.out.printf("User:       %s%n", processInfo.getUsername());
        System.out.printf("Start time: %s%n", format(processInfo.getStartTime()));

        System.out.println("Server statistics");
        StatisticsInfo statisticsInfo = serverInfo.getStatisticsInfo();
        System.out.printf("Connections accepted: %d%n", statisticsInfo.getConnectionsAccepted());
        System.out.printf("Requests handled:     %d%n", statisticsInfo.getRequestsHandled());
    }

    private static String format(Date date) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
        return dateFormat.format(date);
    }
}
