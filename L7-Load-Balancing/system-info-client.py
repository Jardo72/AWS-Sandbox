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

from argparse import ArgumentParser, RawTextHelpFormatter
from collections import Counter
from http.client import HTTPConnection, HTTPSConnection
from json import loads
from typing import Tuple


def print_section_header(title: str) -> None:
    print()
    print()
    print(80 * '-')
    print(f'- {title}')
    print(80 * '-')


def create_cmd_line_args_parser() -> ArgumentParser:
    parser = ArgumentParser(description = "System Info Client", formatter_class = RawTextHelpFormatter)

    parser.add_argument('host',
        help='DNS name or IP address of the destination (e.g. load balancer) the requests are to be sent to',
        type=str)
    parser.add_argument('port',
        help='TCP port of the destination (e.g. load balancer) the requests are to be sent to',
        type=int)
    parser.add_argument('request_count',
        help='minimum for the generated metric value',
        type=int)
    parser.add_argument(
        "-s", "--https",
        dest="https",
        default=False,
        action="store_true",
        help="if specified, HTTPS will be used (plain HTTP is used by default)"
    )

    return parser


def parse_cmd_line_args():
    parser = create_cmd_line_args_parser()
    return parser.parse_args()


def dump_cmd_line_args(params) -> None:
    print_section_header('Test Parameters')
    print(f'Host:          {params.host}')
    print(f'Port:          {params.port}')
    print(f'Request count: {params.request_count}')


def generate_requests(params) -> Tuple[Counter, Counter]:
    if params.https:
        connection = HTTPSConnection(params.host, params.port, timeout=15)
    else:
        connection = HTTPConnection(params.host, params.port, timeout=15)
    http_status_stats: Counter = Counter()
    server_stats: Counter = Counter()

    print_section_header('Requests')
    for i in range(1, params.request_count + 1):
        connection.request('GET', '/api/system-info')
        response = connection.getresponse()
        response_body = response.read().decode()
        json_data = loads(response_body)
        server = json_data['requestInformation']['serverEndpoint']['address']
        http_status_stats.update({ response.status: 1 })
        server_stats.update({ server: 1 })
        if i % 250 == 0:
            print(f'{i} of {params.request_count} requests completed...')

    return (server_stats, http_status_stats)


def print_stats(server_stats: Counter, http_status_stats: Counter) -> None:
    print_section_header('Summary (statistics)')

    print()
    print('Requests per server:')
    for server in server_stats:
        print(f'{server:>16}: {server_stats[server]:7}')

    print()
    print('Requests per HTTP status code:')
    for http_status in http_status_stats:
        print(f'{http_status}: {http_status_stats[http_status]: 7}')


def main() -> None:
    params = parse_cmd_line_args()
    dump_cmd_line_args(params)
    server_stats, http_status_stats = generate_requests(params)
    print_stats(server_stats, http_status_stats)


if __name__ == "__main__":
    main()
