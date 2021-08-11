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

import jch.education.aws.l7loadbalancing.dto.PrimeNumberCalculationRequest;
import jch.education.aws.l7loadbalancing.service.PrimeNumbersCalculationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PrimeNumbersCalculationController {

    @Autowired
    private PrimeNumbersCalculationService primeNumbersCalculationService;

    @Autowired
    private Statistics statistics;
    @PostMapping(value = "/api/calculate-prime-numbers", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Void> startPrimeNumberCalculation(@RequestBody PrimeNumberCalculationRequest request) {
        this.primeNumbersCalculationService.startCalculation(request.getStart(), request.getEnd(),
                request.getSleepPeriodicity(), request.getSleepDurationMillis());
        this.statistics.primeNumbersCalculationStarted();
        return ResponseEntity.ok().build();
    }
}
