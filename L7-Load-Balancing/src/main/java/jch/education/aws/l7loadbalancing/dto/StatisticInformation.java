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

public class StatisticInformation {

    private final long systemInfoRequestCount;

    private final long healthCheckCount;

    private final long primeNumbersCalculationCount;

    public StatisticInformation(long systemInfoRequestCount, long healthCheckCount,
                                long primeNumbersCalculationCount) {
        this.systemInfoRequestCount = systemInfoRequestCount;
        this.healthCheckCount = healthCheckCount;
        this.primeNumbersCalculationCount = primeNumbersCalculationCount;
    }

    public long getSystemInfoRequestCount() {
        return this.systemInfoRequestCount;
    }

    public long getHealthCheckCount() {
        return this.healthCheckCount;
    }

    public long getPrimeNumbersCalculationCount() {
        return this.primeNumbersCalculationCount;
    }
}