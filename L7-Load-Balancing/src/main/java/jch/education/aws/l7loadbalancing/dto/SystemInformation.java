/*
 * Copyright 2020 Jaroslav Chmurny
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
package jch.education.aws.l7loadbalancing.dto;

import java.util.concurrent.atomic.AtomicLong;

public class SystemInformation {

    private static final AtomicLong sequence = new AtomicLong(0);

    private final long requestSequenceNumber = sequence.incrementAndGet();

    private final ServerInformation serverInformation;

    private final ConnectionInformation connectionInformation;

    public SystemInformation(ConnectionInformation connectionInformation) throws Exception {
        this.serverInformation = new ServerInformation();
        this.connectionInformation = connectionInformation;
    }

    public long getRequestSequenceNumber() {
        return this.requestSequenceNumber;
    }

    public ServerInformation getServerInformation() {
        return this.serverInformation;
    }

    public ConnectionInformation getConnectionInformation() {
        return this.connectionInformation;
    }
}
