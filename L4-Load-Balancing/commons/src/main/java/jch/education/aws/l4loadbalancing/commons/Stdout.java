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

import java.net.SocketAddress;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Stdout {

    private static final String DATE_FORMAT = "dd.MM.yyyy HH:mm:ss,SS";

    private Stdout() {}

    public static void println() {
        System.out.println();
    }

    public static void println(String message, Object... args) {
        preprocessArgs(args);
        if (message == null) {
            message = "N/A (null reference)";
        }
        if ((args != null) && (args.length > 0)) {
            message = String.format(message, args);
        }
        System.out.printf("%s: %s", currentTime(), message);
        System.out.println();
    }

    private static void preprocessArgs(Object... args) {
        if (args == null) {
            return;
        }

        for (int i = 0; i < args.length; i++) {
            if (args[i] instanceof SocketAddress) {
                String addressAsString = args[i].toString();
                if (addressAsString.startsWith("/")) {
                    addressAsString = addressAsString.substring(1);
                }
                args[i] = addressAsString;
            }
        }
    }

    public static void printException(Throwable t) {
        System.out.printf("%s: exception caught%n", currentTime());
        t.printStackTrace(System.out);
    }

    private static String currentTime() {
        SimpleDateFormat dateFormat = new SimpleDateFormat(DATE_FORMAT);
        return dateFormat.format(new Date());
    }
}

