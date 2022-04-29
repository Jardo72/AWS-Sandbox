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
# Unless required by applicationlicationlicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from argparse import ArgumentParser, RawTextHelpFormatter
from boto3 import client
from dataclasses import dataclass
from random import randint
from time import sleep, time
from typing import Optional, Tuple
from uuid import uuid4

from commons import Constants, current_timestamp


@dataclass(frozen=True)
class Summary:
    log_stream_name: str
    start_timestamp: str
    end_timestamp: str
    number_of_log_entries: int


class RandomMessageGenerator:

    _templates = [
        'Car passing by, its color is {0}',
        'Text color changed to {0}',
        'Shape color changed to {0}',
        'Background color changed to {0}',
        'Foreground color changed to {0}',
        'Line color changed to {0}',
        'Shape is {0} rectangle',
        'Shape is {0} circle',
        'Shape is {0} triangle',
        'Shape is {0} polygon',
    ]

    _colors = ['red', 'green', 'blue']

    def next_message() -> str:
        color_index = randint(0, len(RandomMessageGenerator._colors) - 1)
        color = RandomMessageGenerator._colors[color_index]

        template_index = randint(0, len(RandomMessageGenerator._templates) - 1)
        template = RandomMessageGenerator._templates[template_index]

        return template.format(color)


def create_command_line_arguments_parser() -> ArgumentParser:
    parser = ArgumentParser(description = "CloudWatch Log Events Generator", formatter_class = RawTextHelpFormatter)

    parser.add_argument('number_of_entries',
        help='number of log entries to be generated',
        type=int)

    return parser


def parse_command_line_arguments():
    parser = create_command_line_arguments_parser()
    return parser.parse_args()


def print_parameters(number_of_entries: int) -> None:
    print()
    print('--------------')
    print('- Parameters')
    print('--------------')
    print(f'{number_of_entries} samples to be generated')
    print()


def current_time_millis() -> int:
    return int(time() * 1000)


def create_log_stream(cloud_watch, log_stream_name: str) -> None:
    try:
        cloud_watch.create_log_group(logGroupName=Constants.log_group_name())
    except Exception:
        # chances are the log group already exists - we do not want to fail in such a case
        pass
    cloud_watch.create_log_stream(logGroupName=Constants.log_group_name(), logStreamName=log_stream_name)
    print(f'Log stream created (name = {log_stream_name})')


def publish_bulk_of_log_entries(cloud_watch, log_stream_name: str, sequence_token: Optional[str]) -> Tuple[int, str]:
    log_events = [ 
        {
            'message': RandomMessageGenerator.next_message(),
            'timestamp': current_time_millis()
        },
        {
            'message': RandomMessageGenerator.next_message(),
            'timestamp': current_time_millis()
        },
        {
            'message': RandomMessageGenerator.next_message(),
            'timestamp': current_time_millis()
        },
        {
            'message': RandomMessageGenerator.next_message(),
            'timestamp': current_time_millis()
        },
        {
            'message': RandomMessageGenerator.next_message(),
            'timestamp': current_time_millis()
        }
    ]

    if sequence_token is None:    
        response = cloud_watch.put_log_events(
            logGroupName=Constants.log_group_name(),
            logStreamName=log_stream_name,
            logEvents=log_events)
    else:
        response = cloud_watch.put_log_events(
            logGroupName=Constants.log_group_name(),
            logStreamName=log_stream_name,
            logEvents=log_events,
            sequenceToken=sequence_token)
    
    return (len(log_events), response['nextSequenceToken'])


def publish_log_entries(number_of_entries: int) -> Summary:
    log_stream_name = str(uuid4())
    cloud_watch = client('logs')
    create_log_stream(cloud_watch, log_stream_name)

    start_timestamp = current_timestamp()
    sequence_token = None
    counter = 0
    while counter < number_of_entries:
        log_event_count, sequence_token = publish_bulk_of_log_entries(cloud_watch, log_stream_name, sequence_token)
        counter += log_event_count
        sleep(0.5)
    end_timestamp = current_timestamp()

    return Summary(log_stream_name, start_timestamp, end_timestamp, counter)


def print_summary(summary: Summary) -> None:
    print()
    print('-----------')
    print('- Summary')
    print('-----------')
    print(f'Log stream:                      {summary.log_stream_name}')
    print(f'Start time:                      {summary.start_timestamp}')
    print(f'End time:                        {summary.end_timestamp}')
    print(f'Number of log entries generated: {summary.number_of_log_entries}')


def main():
    params = parse_command_line_arguments()
    print_parameters(params.number_of_entries)
    summary = publish_log_entries(params.number_of_entries)
    print_summary(summary)


if __name__ == "__main__":
    main()
