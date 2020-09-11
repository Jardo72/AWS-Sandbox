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
import java.net.InetSocketAddress;
import java.net.Socket;

import jch.education.aws.l4loadbalancing.commons.AbstractSocket;
import jch.education.aws.l4loadbalancing.commons.ClientInfo;
import jch.education.aws.l4loadbalancing.commons.ServerInfo;

public class ClientSocket extends AbstractSocket {

    public ClientSocket(String hostname, int port, int timeoutSec) throws IOException {
        super(connect(hostname, port, timeoutSec));
    }

    private static Socket connect(String hostname, int port, int timeoutSec) throws IOException {
        Socket socket = new Socket();
        socket.connect(new InetSocketAddress(hostname, port),  1000 * timeoutSec);
        return socket;
    }

    public void writeClientInfo(ClientInfo clientInfo) throws IOException {
        writeObject(clientInfo);
    }

    public ServerInfo readServerInfo() throws IOException {
        return readObject(ServerInfo.class);
    }
}
