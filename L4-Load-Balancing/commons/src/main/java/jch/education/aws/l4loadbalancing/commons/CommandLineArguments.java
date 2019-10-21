/*
 * Copyright 2019 Jaroslav Chmurny
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
package jch.education.aws.l4loadbalancing.commons;

public class CommandLineArguments {

    private CommandLineArguments() {}

    public static String extractStringValue(String[] commandLineArgs, String name) {
        String result = extractValue(commandLineArgs, name);
        if ((result == null) || (result.length() == 0)) {
            // TODO: throw an exception
        }
        return result;
    }

    public static int extractIntValue(String[] commandLineArgs, String name) {
        String result = extractValue(commandLineArgs, name);
        if ((result == null) || (result.length() == 0)) {
            // TODO: throw an exception
        }
        return Integer.parseInt(result);
    }

    public static String extractStringValue(String[] commandLineArgs, String name, String defaultValue) {
        String result = extractValue(commandLineArgs, name);
        if ((result == null) || (result.length() == 0)) {
            return defaultValue;
        }
        return result;
    }

    public static int extractIntValue(String[] commandLineArgs, String name, int defaultValue) {
        String result = extractValue(commandLineArgs, name);
        if ((result == null) || (result.length() == 0)) {
            return defaultValue;
        }
        return Integer.parseInt(result);
    }

    private static String extractValue(String[] commandLineArgs, String name) {
        for (String singleArg : commandLineArgs) {
            String prefix = String.format("-%s=", name);
            if (singleArg.startsWith(prefix)) {
                int beginIndex = singleArg.indexOf('=') + 1;
                return singleArg.substring(beginIndex);
            }
        }

        return null;
    }
}
