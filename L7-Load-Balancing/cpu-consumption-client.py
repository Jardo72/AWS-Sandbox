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
from dataclasses import dataclass
from datetime import datetime
from http.client import HTTPConnection, HTTPSConnection
from threading import Lock, Thread
from time import perf_counter


@dataclass(frozen=True)
class Summary:
    start_timestamp: str
    end_timestamp: str
    http_status_stats: Counter


class RequestGeneratorThread(Thread):

    _sequence: int = 0

    _lock = Lock()

    def __init__(self, params):
        Thread.__init__(self)
        self._host = params.host
        self._port = params.port
        self._duration_sec = 60 * params.duration_min
        self._https = params.https
        self._id = RequestGeneratorThread._next_id()
        self._http_status_stats = Counter()

    @staticmethod
    def _next_id() -> int:
        with RequestGeneratorThread._lock:
            RequestGeneratorThread._sequence += 1
            return RequestGeneratorThread._sequence

    def run(self) -> None:
        if self._https:
            connection = HTTPSConnection(self._host, self._port, timeout=15)
        else:
            connection = HTTPConnection(self._host, self._port, timeout=15)
        start_time = perf_counter()
        request_count = 0

        while perf_counter() - start_time < self._duration_sec:
            connection.request('GET', '/api/consume-cpu')
            response = connection.getresponse()
            response.read()
            request_count += 1
            self._http_status_stats.update({ response.status: 1 })
            if request_count % 50 == 0:
                execution_time_sec = perf_counter() - start_time
                self._print_status(request_count, execution_time_sec)

    def _print_status(self, request_count: int, execution_time_sec: float) -> None:
        with RequestGeneratorThread._lock:
            print(f'Thread #{self._id}: {request_count} requests completed in {execution_time_sec:.1f} sec...')

    @property
    def http_status_stats(self) -> Counter:
        return self._http_status_stats


def current_timestamp() -> str:
    return datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')


def print_section_header(title: str) -> None:
    print()
    print()
    print(80 * '-')
    print(f'- {title}')
    print(80 * '-')


def create_cmd_line_args_parser() -> ArgumentParser:
    parser = ArgumentParser(description = "CPU Consumption Client", formatter_class = RawTextHelpFormatter)

    parser.add_argument('host',
        help='DNS name or IP address of the destination (e.g. load balancer) the requests are to be sent to',
        type=str)
    parser.add_argument('port',
        help='TCP port of the destination (e.g. load balancer) the requests are to be sent to',
        type=int)
    parser.add_argument('duration_min',
        help='timespan in minutes during which the load is to be generated',
        type=int)
    parser.add_argument('thread_count',
        help='number of threads to be used to generate the requests',
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
    print(f'Host:              {params.host}')
    print(f'Port:              {params.port}')
    print(f'Duration [min]:    {params.duration_min}')
    print(f'Number of threads: {params.thread_count}')


def generate_requests(params) -> Summary:
    print_section_header('Requests')

    start_timestamp = current_timestamp()
    thread_list = []
    for _ in range(1, params.thread_count + 1):
        thread = RequestGeneratorThread(params)
        thread.start()
        thread_list.append(thread)

    http_status_stats: Counter = Counter()
    for thread in thread_list:
        thread.join()
        http_status_stats += thread.http_status_stats
    end_timestamp = current_timestamp()

    return Summary(start_timestamp, end_timestamp, http_status_stats)


def print_stats(summary: Summary) -> None:
    print_section_header('Summary (statistics)')

    print()
    print(f'Start time: {summary.start_timestamp}')
    print(f'End time:   {summary.end_timestamp}')
    print()
    print('Requests per HTTP status code:')
    for http_status in summary.http_status_stats:
        print(f'{http_status}: {summary.http_status_stats[http_status]: 7}')


def main() -> None:
    params = parse_cmd_line_args()
    dump_cmd_line_args(params)
    summary = generate_requests(params)
    print_stats(summary)


if __name__ == "__main__":
    main()
