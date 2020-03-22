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

import java.util.concurrent.Callable;
import java.util.concurrent.atomic.AtomicInteger;

import jch.education.aws.l4loadbalancing.commons.ClientInfo;
import jch.education.aws.l4loadbalancing.commons.ProcessInfo;
import jch.education.aws.l4loadbalancing.commons.ResourceCleanupToolkit;
import jch.education.aws.l4loadbalancing.commons.ServerInfo;
import jch.education.aws.l4loadbalancing.commons.StatisticsInfo;
import jch.education.aws.l4loadbalancing.commons.Stdout;

public class ClientHandler implements Callable<Boolean> {

    private static final AtomicInteger sequence = new AtomicInteger(1);

    private final int id = sequence.getAndIncrement();

    private final ServiceSocket socket;

    private final Statistics statistics;

    private final ProcessInfo processInfo;

    public ClientHandler(ServiceSocket socket, Statistics statistics, ProcessInfo processInfo) {
        this.socket = socket;
        this.statistics = statistics;
        this.processInfo = processInfo;
    }

    @Override
    public Boolean call() throws Exception {
        Stdout.println("New client handler started...");
        ClientInfo clientInfo = null;

        try {
            do {
                clientInfo = this.socket.readClientInfo();
                this.statistics.requestHandled();
                Stdout.println("Request #:     %d", clientInfo.getRequestNumber());
                Stdout.println("Request count: %d", clientInfo.getRequestCount());

                StatisticsInfo statisticsInfo = this.statistics.getSnapshot();
                ServerInfo serverInfo = new ServerInfo(this.processInfo, statisticsInfo);
                this.socket.writeServerInfo(serverInfo);
            } while (clientInfo.isNotLastRequest());

            return true;
        } catch (Exception e) {
            Stdout.printException(e);
            return false;
        } finally {
            ResourceCleanupToolkit.close(this.socket);
        }
    }
}
