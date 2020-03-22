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
package jch.education.aws.l4loadbalancing.server;

import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Date;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import jch.education.aws.l4loadbalancing.commons.CommandLineArguments;
import jch.education.aws.l4loadbalancing.commons.ProcessInfo;
import jch.education.aws.l4loadbalancing.commons.Stdout;

public class Program {
    
    public static void main(String[] args) throws Exception {
        final String ipAddress = CommandLineArguments.extractStringValue(args, "IP-address");
        final int port = CommandLineArguments.extractIntValue(args, "port", 1234);
        Stdout.println("IP address: %s", ipAddress);
        Stdout.println("TCP port:   %d", port);

        final ExecutorService threadPool = Executors.newFixedThreadPool(20);
        final ProcessInfo processInfo = createProcessInfo();
        final Statistics statistics = new Statistics();

        final ServerSocket serverSocket = new ServerSocket();
        serverSocket.bind(new InetSocketAddress(ipAddress, port));
        Stdout.println("Server socket listening on %s...", serverSocket.getLocalSocketAddress());
        while (true) {
            Socket socket = serverSocket.accept();
            Stdout.println("New socket accepted from %s...", socket.getRemoteSocketAddress());
            ServiceSocket serviceSocket = new ServiceSocket(socket);
            statistics.connectionAccepted();
            threadPool.submit(new ClientHandler(serviceSocket, statistics, processInfo));
        }
    }

    private static ProcessInfo createProcessInfo() throws UnknownHostException {
        final String hostname = InetAddress.getLocalHost().getHostName();
        final String username = System.getProperty("user.name");
        return new ProcessInfo(hostname, username, new Date());
    }
}
