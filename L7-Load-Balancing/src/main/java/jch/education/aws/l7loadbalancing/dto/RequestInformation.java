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

import java.util.List;

public class RequestInformation {

    private final String scheme;

    private final boolean isSecure;

    private final ConnectionEndpoint clientEndpoint;

    private final ConnectionEndpoint serverEndpoint;

    private final List<HttpHeader> httpHeaders;

    public RequestInformation(String scheme, boolean isSecure, ConnectionEndpoint clientEndpoint, ConnectionEndpoint serverEndpoint, List<HttpHeader> httpHeaders) throws Exception {
        this.scheme = scheme;
        this.isSecure = isSecure;
        this.clientEndpoint = clientEndpoint;
        this.serverEndpoint = serverEndpoint;
        this.httpHeaders = httpHeaders;
    }

    public String getScheme() {
        return this.scheme;
    }

    public boolean isSecure() {
        return this.isSecure;
    }

    public ConnectionEndpoint getClientEndpoint() {
        return this.clientEndpoint;
    }

    public ConnectionEndpoint getServerEndpoint() {
        return this.serverEndpoint;
    }

    public List<HttpHeader> getHttpHeaders() {
        return this.httpHeaders;
    }
}
