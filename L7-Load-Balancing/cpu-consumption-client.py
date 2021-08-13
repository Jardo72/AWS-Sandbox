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
from sys import argv
from threading import Lock, Thread
from time import perf_counter


class RequestGeneratorThread(Thread):

    _sequence = 0

    _lock = Lock()

    def __init__(self, host, port, duration_min):
        Thread.__init__(self)
        self._host = host
        self._port = port
        self._duration_sec = 60 * duration_min
        self._id = RequestGeneratorThread._next_id()
        self._http_status_stats = Counter()

    @staticmethod
    def _next_id():
        with RequestGeneratorThread._lock:
            RequestGeneratorThread._sequence += 1
            return RequestGeneratorThread._sequence

    def run(self):
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

    def _print_status(self, request_count, execution_time_sec):
        with RequestGeneratorThread._lock:
            print(f'Thread #{self._id}: {request_count} requests completed in {execution_time_sec:.1f} sec...')

    @property
    def http_status_stats(self):
        return self._http_status_stats


def print_section_header(title):
    print()
    print()
    print(80 * '-')
    print(f'- {title}')
    print(80 * '-')


def parse_cmd_line_args():
    host = argv[1]
    port = int(argv[2])
    duration_min = int(argv[3])
    thread_count = int(argv[4])
    return (host, port, duration_min, thread_count)


def dump_cmd_line_args(host, port, duration_min, thread_count):
    print_section_header('Test Parameters')
    print(f'Host:              {host}')
    print(f'Port:              {port}')
    print(f'Duration [min]:    {duration_min}')
    print(f'Number of threads: {thread_count}')


def generate_requests(host, port, duration_min, thread_count):
    print_section_header('Requests')

    thread_list = []
    for _ in range(1, thread_count + 1):
        thread = RequestGeneratorThread(host, port, duration_min)
        thread.start()
        thread_list.append(thread)

    http_status_stats = Counter()
    for thread in thread_list:
        thread.join()
        http_status_stats += thread.http_status_stats

    return http_status_stats


def print_stats(http_status_stats):
    print_section_header('Summary (statistics)')

    print()
    print('Requests per HTTP status code:')
    for http_status in http_status_stats:
        print(f'{http_status}: {http_status_stats[http_status]: 7}')


def main():
    host, port, duration_min, thread_count = parse_cmd_line_args()
    dump_cmd_line_args(host, port, duration_min, thread_count)
    http_status_stats = generate_requests(host, port, duration_min, thread_count)
    print_stats(http_status_stats)


if __name__ == "__main__":
    main()
