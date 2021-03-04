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
from dataclasses import dataclass
from datetime import datetime
from random import randint
from time import sleep
from typing import Sequence, Tuple
from uuid import uuid4

from boto3 import client


pattern = '%Y-%m-%dT%H:%M:%SZ'


@dataclass(frozen=True)
class Sample:
    timestamp: datetime
    value: int
    status_code: int


@dataclass(frozen=True)
class Summary:
    number_of_values: int
    min_value: int
    max_value: int
    avg_value: float
    min_timestamp: datetime
    max_timestamp: datetime


def create_command_line_arguments_parser() -> ArgumentParser:
    parser = ArgumentParser(description = "CloudWatch Metrics Generator", formatter_class = RawTextHelpFormatter)

    parser.add_argument('period_sec',
        help='period (i.e. break between two consecutive samples) in seconds',
        type=int)
    parser.add_argument('number_of_samples',
        help='number of samples (i.e. values) to be generated',
        type=int)

    return parser


def parse_command_line_arguments():
    parser = create_command_line_arguments_parser()
    return parser.parse_args()


def print_parameters(number_of_samples: int, period_sec: int, instance_id: str) -> None:
    print()
    print(f'InstanceId = {instance_id}')
    print(f'{number_of_samples} samples to be generated, period = {period_sec} sec')
    print()


def publish_single_sample(cloud_watch, instance_id: str) -> Sample:
    value = randint(80, 120)
    sample = {
        'MetricName': 'RandomValue',
        'Value': value,
        'Unit': 'None',
        'Dimensions': [
            {
                'Name': 'InstanceId',
                'Value': instance_id
            }
        ]
    }
    response = cloud_watch.put_metric_data(Namespace='JCH', MetricData=[sample])
    status_code = response['ResponseMetadata']['HTTPStatusCode']
    return Sample(datetime.utcnow(), value, status_code)


def publish_samples(number_of_samples: int, period_sec: int, instance_id: str) -> Tuple[Sample, ...]:
    cloud_watch = client('cloudwatch')
    samples = []
    for i in range(0, number_of_samples):
        sample = publish_single_sample(cloud_watch, instance_id)
        timestamp = sample.timestamp.strftime(pattern)
        print(f'{i + 1}/{number_of_samples} (value = {sample.value}, status code = {sample.status_code}, timestamp = {timestamp})')
        samples.append(sample)
        if i < number_of_samples - 1:
            sleep(period_sec)
    return tuple(samples)


def calculate_summary(samples: Sequence[Sample]) -> Summary:
    relevant_samples = filter(lambda s: s.status_code == 200, samples)
    relevant_samples = list(relevant_samples)
    values = list(map(lambda s: s.value, relevant_samples))
    number_of_values = len(values)
    avg_value = sum(values) / number_of_values
    min_value = min(values)
    max_value = max(values)
    start_time = relevant_samples[0].timestamp
    end_time = relevant_samples[-1].timestamp
    return Summary(number_of_values, min_value, max_value, avg_value, start_time, end_time)


def print_summary(instance_id: str, summary: Summary) -> None:
    min_timestamp = summary.min_timestamp.strftime(pattern)
    max_timestamp = summary.max_timestamp.strftime(pattern)
    print()
    print(f'Relevant values (status code 200): {summary.number_of_values}')
    print(f'Instance ID:    {instance_id}')
    print(f'Min value:      {summary.min_value}')
    print(f'Max value:      {summary.max_value}')
    print(f'Avg value:      {summary.avg_value}')
    print(f'Min timestamp:  {min_timestamp}')
    print(f'Max timestamp:  {max_timestamp}')


def main() -> None:
    params = parse_command_line_arguments()
    instance_id = str(uuid4())

    print_parameters(params.number_of_samples, params.period_sec, instance_id)
    samples = publish_samples(params.number_of_samples, params.period_sec, instance_id)
    summary = calculate_summary(samples)
    print_summary(instance_id, summary)


if __name__ == "__main__":
    main()
