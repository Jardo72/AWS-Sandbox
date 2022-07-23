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
    values: Tuple[int, ...]
    start_timestamp: str
    end_timestamp: str

    @property
    def min_value(self) -> int:
        return min(self.values)

    @property
    def max_value(self) -> int:
        return max(self.values)

    @property
    def avg_value(self) -> float:
        return sum(self.values) / len(self.values)


def create_command_line_arguments_parser() -> ArgumentParser:
    parser = ArgumentParser(description = "CloudWatch Log Events Generator", formatter_class = RawTextHelpFormatter)

    parser.add_argument('period_sec',
        help='period (i.e. break between two consecutive log entries) in seconds',
        type=int)
    parser.add_argument('number_of_entries',
        help='number of log entries to be generated',
        type=int)
    parser.add_argument('min',
        help='minimum for the generated metric value',
        type=int)
    parser.add_argument('max',
        help='maximum for the generated metric value',
        type=int)
    parser.add_argument('--no_filter',
        help='do not create metric filter (filter is created if this option is not specified)',
        action='store_true')

    return parser


def parse_command_line_arguments():
    parser = create_command_line_arguments_parser()
    return parser.parse_args()


def print_parameters(number_of_entries: int, period_sec: int, min: int, max: int, no_filter: bool) -> None:
    create_filter = 'No.' if no_filter else 'Yes.'
    print()
    print('--------------')
    print('- Parameters')
    print('--------------')
    print(f'{number_of_entries} samples to be generated, period = {period_sec} sec')
    print(f'Range for the random values = [{min}; {max}]')
    print(f'Create metric filter? {create_filter}')
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


def create_metric_filter(cloud_watch, no_filter: bool) -> None:
    if no_filter:
        print('Metric filter not requested')
        return

    metric_transformations = [
        {
            'metricName': Constants.metric_from_log(),
            'metricNamespace': Constants.namespace(),
            'metricValue': '$randomValue'
        },
    ]
    cloud_watch.put_metric_filter(
        logGroupName=Constants.log_group_name(),
        filterName='RandomValueFilter',
        filterPattern='[message, randomValue]',
        metricTransformations=metric_transformations)
    print('Metric filter created')


def publish_single_log_entry(cloud_watch, log_stream_name: str, min: int, max: int, sequence_token: Optional[str]) -> Tuple[int, str]:
    timestamp = current_time_millis()
    value = randint(min, max)
    log_message = f'random-value-for-metric-filter, {value}'
    log_events = [ 
        { 
            'message': f'Dummy event not relevant for the metric filter (random value = {uuid4()})',
            'timestamp': timestamp
        },
        { 
            'message': log_message,
            'timestamp': timestamp + randint(5, 220)
        },
        { 
            'message': f'Dummy event irrelevant for the metric filter (random value = {uuid4()})',
            'timestamp': timestamp + randint(230, 750)
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
    
    return (value, response['nextSequenceToken'])


def publish_log_entries(number_of_entries: int, period_sec: int, min: int, max: int, no_filter: bool) -> Summary:
    log_stream_name = str(uuid4())
    cloud_watch = client('logs')
    create_log_stream(cloud_watch, log_stream_name)
    create_metric_filter(cloud_watch, no_filter)

    start_timestamp = current_timestamp()
    sequence_token = None
    values = []
    for i in range(0, number_of_entries):
        value, sequence_token = publish_single_log_entry(cloud_watch, log_stream_name, min, max, sequence_token)
        values.append(value)
        if i < number_of_entries - 1:
            sleep(period_sec)
    end_timestamp = current_timestamp()

    return Summary(log_stream_name, tuple(values), start_timestamp, end_timestamp)


def print_summary(summary: Summary) -> None:
    print()
    print('-----------')
    print('- Summary')
    print('-----------')
    print(f'Log stream:                  {summary.log_stream_name}')
    print(f'Start time:                  {summary.start_timestamp}')
    print(f'End time:                    {summary.end_timestamp}')
    print(f'Number of values generated:  {len(summary.values)}')
    print(f'Min value:                   {summary.min_value}')
    print(f'Max value:                   {summary.max_value}')
    print(f'Avg value:                   {summary.avg_value}')


def main():
    params = parse_command_line_arguments()
    print_parameters(params.number_of_entries, params.period_sec, params.min, params.max, params.no_filter)
    summary = publish_log_entries(params.number_of_entries, params.period_sec, params.min, params.max, params.no_filter)
    print_summary(summary)


# https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_PutLogEvents.html
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/logs.html#CloudWatchLogs.Client.describe_log_groups
if __name__ == "__main__":
    main()
