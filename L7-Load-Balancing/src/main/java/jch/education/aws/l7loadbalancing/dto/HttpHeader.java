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

import java.util.Enumeration;
import java.util.LinkedList;
import java.util.List;

public class HttpHeader {

    private final String name;

    private final List<String> values;

    public HttpHeader(String name, Enumeration<String> values) {
        this.name = name;
        List<String> valueList = new LinkedList<String>();
        while (values.hasMoreElements()) {
            valueList.add(values.nextElement());
        }
        this.values = valueList;
    }

    public String getName() {
        return this.name;
    }

    public List<String> getValues() {
        return this.values;
    }
}
