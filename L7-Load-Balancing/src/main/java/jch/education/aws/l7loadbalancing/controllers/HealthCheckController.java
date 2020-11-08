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

import java.util.concurrent.atomic.AtomicReference;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthCheckController {

    private static final Logger log = LoggerFactory.getLogger(HealthCheckController.class);

    private final AtomicReference<HealthStatus> currentStatus = new AtomicReference<>(HealthStatus.OK);

    @Autowired
    private Statistics statistics;

    @GetMapping(value = "/api/health-check")
    public ResponseEntity<Void> doHealthCheck() {
        this.statistics.healthCheckExecuted();
        HealthStatus currentStatus = this.currentStatus.get();
        if (currentStatus == HealthStatus.OK) {
            return ResponseEntity.ok().build();
        }
        if (currentStatus == HealthStatus.ERROR) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }

        hangCurrentThreadForewer();
        throw new IllegalStateException("This statement should never be reached.");
    }

    private void hangCurrentThreadForewer() {
        while (true) {
            try {
                Thread.sleep(60 * 1000);
            } catch (InterruptedException ignore) {}
        }
    }

    @GetMapping(value = "/api/health-status", produces = MediaType.TEXT_PLAIN_VALUE)
    public ResponseEntity<String> getHealthStatus() {
        HealthStatus currentStatus = this.currentStatus.get();
        log.info("Going to return current health status ({})", currentStatus);
        return ResponseEntity.ok().body(currentStatus.toString());
    }

    @PutMapping(value = "/api/health-status")
    public ResponseEntity<Void> setHealthStatus(@RequestParam(name = "status") String status) {
        log.info("Going to set health-status to {}", status);
        if ("OK".equalsIgnoreCase(status)) {
            this.currentStatus.set(HealthStatus.OK);
            return ResponseEntity.ok().build();
        }
        if ("ERROR".equalsIgnoreCase(status)) {
            this.currentStatus.set(HealthStatus.ERROR);
            return ResponseEntity.ok().build();
        }
        if ("HANG".equalsIgnoreCase(status)) {
            this.currentStatus.set(HealthStatus.HANG);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
    }

    private enum HealthStatus {
        OK, ERROR, HANG
    }
}
