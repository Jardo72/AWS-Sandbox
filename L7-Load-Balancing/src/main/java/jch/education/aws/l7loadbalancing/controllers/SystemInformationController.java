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
package jch.education.aws.l7loadbalancing.controllers;

import java.util.Enumeration;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import jch.education.aws.l7loadbalancing.dto.ConnectionEndpoint;
import jch.education.aws.l7loadbalancing.dto.HttpHeader;
import jch.education.aws.l7loadbalancing.dto.RequestInformation;
import jch.education.aws.l7loadbalancing.dto.StatisticInformation;
import jch.education.aws.l7loadbalancing.dto.SystemInformation;

@RestController
public class SystemInformationController {

    private static final Statistics statistics = new Statistics();

    @GetMapping(value = "/api/system-info", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<SystemInformation> systemInformation(HttpServletRequest request) throws Exception {
        statistics.requestHandled();

        ConnectionEndpoint clientEndpoint = new ConnectionEndpoint(request.getRemoteAddr(), request.getRemotePort());
        ConnectionEndpoint serverEndpoint = new ConnectionEndpoint(request.getLocalAddr(), request.getLocalPort());
        List<HttpHeader> httpHeaders = extractHeadersFrom(request);
        String scheme = request.getScheme();
        boolean isSecure = request.isSecure();

        RequestInformation requestInfo = new RequestInformation(scheme, isSecure, clientEndpoint, serverEndpoint, httpHeaders);
        StatisticInformation statisticInfo = statistics.getSnapshot();
        SystemInformation sysInfo = new SystemInformation(requestInfo, statisticInfo);
        return new ResponseEntity<SystemInformation>(sysInfo, HttpStatus.OK);
    }

    private static List<HttpHeader> extractHeadersFrom(HttpServletRequest request) {
        List<HttpHeader> result = new LinkedList<HttpHeader>();
        Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String name = headerNames.nextElement();
            Enumeration<String> values = request.getHeaders(name);
            result.add(new HttpHeader(name, values));
        }
        return result;
    }
}
