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
package jch.education.aws.l7loadbalancing.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.atomic.AtomicLong;

class PrimeNumbersCalculationTask implements Callable<PrimeNumbersCalculationResult> {

    private static final Logger log = LoggerFactory.getLogger(PrimeNumbersCalculationTask.class);

    private static final AtomicLong SEQUENCE = new AtomicLong(1);

    private final long taskId = SEQUENCE.getAndIncrement();

    private final int start;

    private final int end;

    public PrimeNumbersCalculationTask(int start, int end) {
        this.start = start;
        this.end = end;
    }

    @Override
    public PrimeNumbersCalculationResult call() throws Exception {
        log.info("Starting prime numbers calculation #{}, range [{}; {}]", this.taskId, this.start, this.end);

        List<Integer> primeNumbers = new LinkedList<>();
        for (int number = this.start; number <= this.end; number++) {
            if (isPrimeNumber(number)) {
                primeNumbers.add(number);
            }
        }

        log.info("Prime numbers calculation #{}, range [{}; {}] completed, {} prime numbers found",
                this.taskId, this.start, this.end, primeNumbers.size());
        return new PrimeNumbersCalculationResult(this.start, this.end, primeNumbers);
    }

    private static boolean isPrimeNumber(int number) {
        for (int i = 2; i <= Math.sqrt(number); i++) {
            if (number % i == 0) {
                return false;
            }
        }
        return true;
    }
}
