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

import java.io.IOException;

import java.net.InetSocketAddress;
import java.net.ServerSocket;

import jch.education.aws.l4loadbalancing.commons.CommandLineArguments;

public class Program {
    
    public static void main(String[] args) throws IOException {
        // TODO:
        // - two command line arguments:
        //   + IP address to bind the listening socket to
        //   + TCP port to open
        System.out.println("Hello world!!! My name is Server.");
        final String ipAddress = CommandLineArguments.extractStringValue(args, "");
        final int port = CommandLineArguments.extractIntValue(args, "", 1234);

        ServerSocket serverSocket = new ServerSocket();
        serverSocket.bind(new InetSocketAddress(ipAddress, port));
        while (true) {
            ServiceSocket serviceSocket = new ServiceSocket(serverSocket.accept());
        }
    }
}
