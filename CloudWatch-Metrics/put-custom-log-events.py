#
# Copyright 2021 Jaroslav Chmurny
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

from argparse import (
    ArgumentParser,
    RawTextHelpFormatter
)
from boto3 import client
from json import dumps
from random import randint
from time import sleep
from typing import Optional, Tuple
from uuid import uuid4

from commons import (
    Constants,
    LogEventsSummary,
    create_log_stream,
    current_timestamp,
    current_time_millis
)


class RandomMessageGenerator:

    _http_methods = ["GET", "POST", "PUT", "DELETE"]

    _http_status_codes = [200, 201, 400, 401, 403, 500]

    _resource_path = [
        "/employee/{id}",
        "/employee/all",
        "/manager/{id}",
        "/manager/all",
        "/organizational-unit/{id}",
        "/organizational-unit/all",
    ]

    @staticmethod
    def next_message() -> str:
        resource_path = RandomMessageGenerator._random_resource_path()
        http_method = "GET" if "all" in resource_path else RandomMessageGenerator._random_http_method()
        message = {
            "httpMethod": http_method,
            "resourcePath": resource_path,
            "statusCode": RandomMessageGenerator._random_status_code(),
            "duration": RandomMessageGenerator._random_duration()
        }
        return dumps(message)

    @staticmethod
    def _random_status_code() -> int:
        random_index = randint(0, len(RandomMessageGenerator._http_status_codes) - 1)
        return RandomMessageGenerator._http_status_codes[random_index]

    @staticmethod
    def _random_http_method() -> str:
        random_index = randint(0, len(RandomMessageGenerator._http_methods) - 1)
        return RandomMessageGenerator._http_methods[random_index]

    @staticmethod
    def _random_resource_path() -> str:
        random_index = randint(0, len(RandomMessageGenerator._resource_path) - 1)
        result = RandomMessageGenerator._resource_path[random_index]
        return result.format(id=str(uuid4()))

    @staticmethod
    def _random_duration() -> int:
        return randint(27, 3749)


def create_command_line_arguments_parser() -> ArgumentParser:
    parser = ArgumentParser(description = "CloudWatch Log Events Generator", formatter_class = RawTextHelpFormatter)

    parser.add_argument('number_of_events',
        help='number of log events to be generated',
        type=int)

    return parser


def parse_command_line_arguments():
    parser = create_command_line_arguments_parser()
    return parser.parse_args()


def print_parameters(number_of_events: int) -> None:
    print()
    print('--------------')
    print('- Parameters')
    print('--------------')
    print(f'{number_of_events} log events to be generated')
    print()


def publish_bulk_of_log_entries(cloud_watch, log_stream_name: str, sequence_token: Optional[str]) -> Tuple[int, str]:
    timestamp = current_time_millis()
    log_events = []
    for _ in range(0, 100):
        log_events.append({
            'message': RandomMessageGenerator.next_message(),
            'timestamp': timestamp
        })
        timestamp += 3

    if sequence_token is None:    
        response = cloud_watch.put_log_events(
            logGroupName=Constants.insights_log_group_name(),
            logStreamName=log_stream_name,
            logEvents=log_events)
    else:
        response = cloud_watch.put_log_events(
            logGroupName=Constants.insights_log_group_name(),
            logStreamName=log_stream_name,
            logEvents=log_events,
            sequenceToken=sequence_token)
    
    return (len(log_events), response['nextSequenceToken'])


def publish_log_entries(number_of_entries: int) -> LogEventsSummary:
    log_stream_name = str(uuid4())
    cloud_watch = client('logs')
    create_log_stream(cloud_watch, Constants.insights_log_group_name(), log_stream_name)

    start_timestamp = current_timestamp()
    sequence_token = None
    counter = 0
    while counter < number_of_entries:
        log_event_count, sequence_token = publish_bulk_of_log_entries(cloud_watch, log_stream_name, sequence_token)
        counter += log_event_count
        sleep(0.5)
    end_timestamp = current_timestamp()

    return LogEventsSummary(log_stream_name, start_timestamp, end_timestamp, counter)


def print_summary(summary: LogEventsSummary) -> None:
    print()
    print('-----------')
    print('- Summary')
    print('-----------')
    print(f'Log stream:                     {summary.log_stream_name}')
    print(f'Start time:                     {summary.start_timestamp}')
    print(f'End time:                       {summary.end_timestamp}')
    print(f'Number of log events generated: {summary.number_of_log_events}')


def main():
    params = parse_command_line_arguments()
    print_parameters(params.number_of_events)
    summary = publish_log_entries(params.number_of_events)
    print_summary(summary)


if __name__ == "__main__":
    main()
