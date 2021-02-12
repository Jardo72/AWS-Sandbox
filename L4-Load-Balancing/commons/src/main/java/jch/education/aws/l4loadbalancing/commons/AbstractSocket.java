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

import java.io.Closeable;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.SocketAddress;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.ObjectMapper;

public class AbstractSocket implements Closeable {

    private final ObjectMapper objectMapper = createObjectMapper();

    private final Socket socket;

    private final InputStream input;
    
    private final OutputStream output;

    protected AbstractSocket(Socket socket) throws IOException {
        this.socket = socket;
        this.input = socket.getInputStream();
        this.output = socket.getOutputStream();
    }

    private static ObjectMapper createObjectMapper() {
        return new ObjectMapper()
                .configure(JsonGenerator.Feature.AUTO_CLOSE_TARGET, false)
                .configure(JsonParser.Feature.AUTO_CLOSE_SOURCE, false);
    }

    protected <T> T readObject(Class<T> clazz) throws IOException {
        return this.objectMapper.readValue(this.input, clazz);
    }

    public void writeObject(Object object) throws IOException {
        // TODO: remove the comments
        // http://inventwithpython.com/makinggames.pdf
        this.objectMapper.writeValue(this.output, object);
    }

    public String getLocalAddress() {
        return formatAddress(this.socket.getLocalSocketAddress());
    }

    public String getRemoteAddress() {
        return formatAddress(this.socket.getRemoteSocketAddress());
    }

    private static String formatAddress(SocketAddress address) {
        if (address == null) {
            return "<N/A>";
        }
        String result = address.toString();
        if (result.startsWith("/")) {
            result = result.substring(1);
        }
        return result;
    }

    @Override
    public void close() {
        ResourceCleanupToolkit.close(this.output);
        ResourceCleanupToolkit.close(this.input);
        ResourceCleanupToolkit.close(this.socket);
    }
}
