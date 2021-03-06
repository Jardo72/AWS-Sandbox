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
package jch.education.aws.l4loadbalancing.commons;

import com.fasterxml.jackson.annotation.JsonProperty;

public class ServerInfo {

    @JsonProperty(value = "processInfo", required = true)
    private ProcessInfo processInfo;

    @JsonProperty(value = "connectionInfo", required = true)
    private ConnectionInfo connectionInfo;

    @JsonProperty(value = "statisticsInfo", required = true)
    private StatisticsInfo statisticsInfo;

    public ServerInfo() {}

    public ServerInfo(ProcessInfo processInfo, ConnectionInfo connectionInfo, StatisticsInfo statisticsInfo) {
        this.processInfo = processInfo;
        this.connectionInfo = connectionInfo;
        this.statisticsInfo = statisticsInfo;
    }

    public ProcessInfo getProcessInfo() {
        return this.processInfo;
    }

    public ConnectionInfo getConnectionInfo() {
        return this.connectionInfo;
    }

    public StatisticsInfo getStatisticsInfo() {
        return this.statisticsInfo;
    }
}
