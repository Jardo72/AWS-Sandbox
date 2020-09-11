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

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import jch.education.aws.l4loadbalancing.commons.ClientInfo;
import jch.education.aws.l4loadbalancing.commons.CommandLineArguments;
import jch.education.aws.l4loadbalancing.commons.ProcessInfo;
import jch.education.aws.l4loadbalancing.commons.ResourceCleanupToolkit;
import jch.education.aws.l4loadbalancing.commons.ServerInfo;
import jch.education.aws.l4loadbalancing.commons.StatisticsInfo;
import jch.education.aws.l4loadbalancing.commons.Stdout;
import jch.education.aws.l4loadbalancing.commons.Timing;

public class Program {
    
    public static void main(String[] args) throws Exception {
        ClientSocket clientSocket = null;

        try {
            final String ipAddress = CommandLineArguments.extractStringValue(args, "IP-address");
            final int port = CommandLineArguments.extractIntValue(args, "port", 1234);
            final int requestCount = CommandLineArguments.extractIntValue(args, "request-count", 1);
            final int breakBetweenRequestsSec = CommandLineArguments.extractIntValue(args, "break-between-requests-sec", 5);
            Stdout.println("IP address:                   %s", ipAddress);
            Stdout.println("TCP port:                     %d", port);
            Stdout.println("Request count:                %d", requestCount);
            Stdout.println("Break between requests [sec]: %d", breakBetweenRequestsSec);

            final String clientId = UUID.randomUUID().toString();
            clientSocket = new ClientSocket(ipAddress, port, 5);
            for (int i = 1; i <= requestCount; i++) {
                ClientInfo clientInfo = new ClientInfo(clientId, i, requestCount);
                clientSocket.writeClientInfo(clientInfo);
                print(clientInfo);

                ServerInfo serverInfo = clientSocket.readServerInfo();
                print(serverInfo);
                Timing.sleep(breakBetweenRequestsSec, TimeUnit.SECONDS);
            }
        } finally {
            ResourceCleanupToolkit.close(clientSocket);
        }
    }

    private static void print(ClientInfo clientInfo) {
        Stdout.println();
        Stdout.println("Client info sent to server");
        Stdout.println("Client ID: %s", clientInfo.getClientId());
        Stdout.println("Request #: %d", clientInfo.getRequestNumber());
    }

    private static void print(ServerInfo serverInfo) {
        final StatisticsInfo statisticsInfo = serverInfo.getStatisticsInfo();
        final ProcessInfo processInfo = serverInfo.getProcessInfo();

        Stdout.println();
        Stdout.println("Server info received from server");
        Stdout.println("Hostname:             %s", processInfo.getHostname());
        Stdout.println("User:                 %s", processInfo.getUsername());
        Stdout.println("Start time:           %s", format(processInfo.getStartTime()));
        Stdout.println("Connections accepted: %d", statisticsInfo.getConnectionsAccepted());
        Stdout.println("Requests handled:     %d", statisticsInfo.getRequestsHandled());
    }

    private static String format(Date date) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MMM-yyyy HH:mm:ss Z");
        return dateFormat.format(date);
    }
}
