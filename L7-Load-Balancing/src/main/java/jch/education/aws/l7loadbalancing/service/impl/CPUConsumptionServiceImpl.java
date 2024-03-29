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

import jch.education.aws.l7loadbalancing.service.CPUConsumptionService;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
@Scope(ConfigurableBeanFactory.SCOPE_SINGLETON)
public class CPUConsumptionServiceImpl implements CPUConsumptionService {

    @Override
    public void consume() {
        final long startTime = System.currentTimeMillis();

        BigDecimal result = BigDecimal.ONE;
        for (int i = 2; i <= Integer.MAX_VALUE; i++) {
            result = result.multiply(new BigDecimal(i));
            if (i % 1000 == 0) {
                sleep();
                long executionTime = System.currentTimeMillis() - startTime;
                if (executionTime >= 1000) {
                    return;
                }
            }
        }
    }

    private static void sleep() {
        try {
            Thread.sleep(10);
        } catch (InterruptedException ignore) {}
    }
}
