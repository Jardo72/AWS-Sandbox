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

import jch.education.aws.l7loadbalancing.service.CPUConsumptionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CPUConsumptionController {

    private static final Logger log = LoggerFactory.getLogger(CPUConsumptionController.class);

    @Autowired
    private CPUConsumptionService cpuConsumptionService;

    @Autowired
    private Statistics statistics;

    @GetMapping(value = "/api/consume-cpu", produces = MediaType.TEXT_PLAIN_VALUE)
    public ResponseEntity<String> consumeCpu() {
        final long startTime = System.currentTimeMillis();

        this.cpuConsumptionService.consume();
        final long durationMillis = System.currentTimeMillis() - startTime;
        this.statistics.cpuConsumed();

        String message = String.format("CPU consumed for %d ms", durationMillis);
        log.info(message);

        return new ResponseEntity<>(message, HttpStatus.OK);
    }
}
