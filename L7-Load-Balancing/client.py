#
# Copyright 2020 Jaroslav Chmurny
#
# This file is part of AWS Sandbox.
#
# AWS Sandbox is free software developed for educational purposes. It
# is licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from collections import Counter
from http.client import HTTPConnection
from json import loads
from sys import argv


def print_section_header(title):
    print()
    print()
    print(80 * '-')
    print(f'- {title}')
    print(80 * '-')


def parse_cmd_line_args():
    host = argv[1]
    port = int(argv[2])
    request_count = int(argv[3])
    return (host, port, request_count)


def dump_cmd_line_args(host, port, request_count):
    print_section_header('Test Parameters')
    print(f'Host:          {host}')
    print(f'Port:          {port}')
    print(f'Request count: {request_count}')


def generate_requests(host, port, request_count):
    connection = HTTPConnection(host, port, timeout=15)
    http_status_stats = Counter()
    server_stats = Counter()

    print_section_header('Requests')
    for i in range(1, request_count + 1):
        connection.request('GET', '/api/system-info')
        response = connection.getresponse()
        response_body = response.read().decode()
        json_data = loads(response_body)
        server = json_data['requestInformation']['serverEndpoint']['address']
        http_status_stats.update({ response.status: 1 })
        server_stats.update({ server: 1 })
        if i % 250 == 0:
            print(f'{i} of {request_count} requests completed...')

    return (server_stats, http_status_stats)


def print_stats(server_stats, http_status_stats):
    print_section_header('Summary (statistics)')

    print()
    print('Requests per server:')
    for server in server_stats:
        print(f'{server:>16}: {server_stats[server]:7}')

    print()
    print('Requests per HTTP status code:')
    for http_status in http_status_stats:
        print(f'{http_status}: {http_status_stats[http_status]: 7}')


def main():
    host, port, request_count = parse_cmd_line_args()
    dump_cmd_line_args(host, port, request_count)
    server_stats, http_status_stats = generate_requests(host, port, request_count)
    print_stats(server_stats, http_status_stats)


if __name__ == "__main__":
    main()
