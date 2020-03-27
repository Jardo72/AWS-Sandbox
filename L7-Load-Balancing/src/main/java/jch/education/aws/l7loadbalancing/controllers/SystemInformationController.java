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

import javax.servlet.http.HttpServletRequest;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import jch.education.aws.l7loadbalancing.dto.ConnectionEndpoint;
import jch.education.aws.l7loadbalancing.dto.ConnectionInformation;
import jch.education.aws.l7loadbalancing.dto.StatisticInformation;
import jch.education.aws.l7loadbalancing.dto.SystemInformation;

@RestController
public class SystemInformationController {

    private static final Statistics statistics = new Statistics();

    @RequestMapping(value = "/api/system-info", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<SystemInformation> systemInformation(HttpServletRequest request) throws Exception {
        statistics.requestHandled();

        ConnectionEndpoint clientEndpoint = new ConnectionEndpoint(request.getRemoteAddr(), request.getRemotePort());
        ConnectionEndpoint serverEndpoint = new ConnectionEndpoint(request.getLocalAddr(), request.getLocalPort());
        String scheme = request.getScheme();
        boolean isSecure = request.isSecure();

        ConnectionInformation connectionInfo = new ConnectionInformation(scheme, isSecure, clientEndpoint, serverEndpoint);
        StatisticInformation statisticInfo = statistics.getSnapshot();
        SystemInformation sysInfo = new SystemInformation(connectionInfo, statisticInfo);
        return new ResponseEntity<SystemInformation>(sysInfo, HttpStatus.OK);
    }
}
