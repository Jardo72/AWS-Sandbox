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

public class PrimeNumberCalculationRequest {

    private int start;

    private int end;

    private int sleepPeriodicity;

    private int sleepDurationMillis;

    public int getStart() {
        return start;
    }

    public void setStart(int start) {
        this.start = start;
    }

    public int getEnd() {
        return end;
    }

    public void setEnd(int end) {
        this.end = end;
    }

    public int getSleepPeriodicity() {
        return this.sleepPeriodicity;
    }

    public void setSleepPeriodicity(int sleepPeriodicity) {
        this.sleepPeriodicity = sleepPeriodicity;
    }

    public int getSleepDurationMillis() {
        return this.sleepDurationMillis;
    }

    public void setSleepDurationMillis(int sleepDurationMillis) {
        this.sleepDurationMillis = sleepDurationMillis;
    }
}
