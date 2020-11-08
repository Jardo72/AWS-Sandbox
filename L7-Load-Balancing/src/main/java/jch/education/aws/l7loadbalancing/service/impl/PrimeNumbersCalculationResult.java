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

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class PrimeNumbersCalculationResult {

    private final int start;

    private final int end;

    private final List<Integer> primeNumbers;

    public PrimeNumbersCalculationResult(int start, int end, List<Integer> primeNumbers) {
        this.start = start;
        this.end = end;
        this.primeNumbers = immutableCloneOf(primeNumbers);
    }

    private static List<Integer> immutableCloneOf(List<Integer> original) {
        List<Integer> clone = new ArrayList<>(original);
        return Collections.unmodifiableList(clone);
    }

    public int getStart() {
        return this.start;
    }

    public int getEnd() {
        return this.end;
    }

    public List<Integer> getPrimeNumbers() {
        return this.primeNumbers;
    }
}
