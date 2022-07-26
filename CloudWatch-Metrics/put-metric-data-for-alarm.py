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
from dataclasses import dataclass
from json import load
from random import randint
from time import sleep
from typing import Any, Dict, Sequence, Tuple
from datetime import datetime
from uuid import uuid4

from boto3 import client

from commons import (
    Constants,
    MetricDataSummary,
    Sample,
    calculate_summary,
    print_summary
)


@dataclass(frozen=True)
class ConfigEntry:
    min_value: int
    max_value: int
    number_of_samples: int


@dataclass(frozen=True)
class Config:
    period_sec: int
    schedule_entries: Tuple[ConfigEntry, ...]

    @property
    def number_of_batches(self):
        return len(self.schedule_entries)

    @property
    def overall_number_of_samples(self):
        return sum(map(lambda e: e.number_of_samples, self.schedule_entries))


def create_command_line_arguments_parser() -> ArgumentParser:
    parser = ArgumentParser(description = "CloudWatch Metrics Generator", formatter_class = RawTextHelpFormatter)
    parser.add_argument('config_file', help='name of the configuration file')
    return parser


def parse_command_line_arguments():
    parser = create_command_line_arguments_parser()
    return parser.parse_args()


def print_parameters(config: Config, instance_id: str) -> None:
    print()
    print(f'InstanceId:                      {instance_id}')
    print(f'Number of batches:               {config.number_of_batches}')
    print(f'Number of samples (all batches): {config.overall_number_of_samples}')
    print(f'Period:                          {config.period_sec} sec')
    print()


def read_config_entry(json_data: Dict[str, Any]) -> ConfigEntry:
    return ConfigEntry(min_value=json_data['minValue'],
        max_value=json_data['maxValue'],
        number_of_samples=json_data['numberOfSamples'])


def read_config(filename: str) -> Config:
    with open(filename) as json_file:
        json_data = load(json_file)

    period_sec = json_data['periodSec']
    entries = [read_config_entry(entry) for entry in json_data['scheduleEntries']]
    return Config(period_sec, tuple(entries))


def publish_single_sample(cloud_watch, config_entry: ConfigEntry, instance_id: str) -> Sample:
    value = randint(config_entry.min_value, config_entry.max_value)
    sample = {
        'MetricName': Constants.metric(),
        'Value': value,
        'Unit': 'None',
        'Dimensions': [
            {
                'Name': 'InstanceId',
                'Value': instance_id
            }
        ]
    }
    response = cloud_watch.put_metric_data(Namespace=Constants.namespace(), MetricData=[sample])
    status_code = response['ResponseMetadata']['HTTPStatusCode']
    return Sample(datetime.utcnow(), value, status_code)


def publish_config_entry_samples(cloud_watch, config_entry: ConfigEntry, instance_id: str, period_sec: int) -> MetricDataSummary:
    samples = []
    for i in range(config_entry.number_of_samples):
        sample = publish_single_sample(cloud_watch, config_entry, instance_id)
        timestamp = sample.timestamp.strftime(Constants.timestamp_format())
        print(f'{i + 1}/{config_entry.number_of_samples} (value = {sample.value}, status code = {sample.status_code}, timestamp = {timestamp})')
        samples.append(sample)
        if i < config_entry.number_of_samples - 1:
            sleep(period_sec)
    return calculate_summary(samples)


def publish_samples(config: Config, instance_id: str) -> Tuple[MetricDataSummary, ...]:
    cloud_watch = client('cloudwatch')
    summaries = []
    for index, entry in enumerate(config.schedule_entries):
        print()
        print(80 * '-')
        print(f'Going to generate batch {index + 1}/{len(config.schedule_entries)}')
        print(f'Values between {entry.min_value} and {entry.max_value}')
        summary = publish_config_entry_samples(cloud_watch, entry, instance_id, config.period_sec)
        summaries.append(summary)
    return tuple(summaries)


def print_summaries(summaries: Sequence[MetricDataSummary], instance_id: str) -> None:
    for index, single_summary in enumerate(summaries):
        print()
        print(f'Batch {index + 1}/{len(summaries)}')
        print_summary(instance_id, single_summary)


def main() -> None:
    params = parse_command_line_arguments()
    config = read_config(params.config_file)
    instance_id = str(uuid4())
    print_parameters(config, instance_id)
    summaries = publish_samples(config, instance_id)
    print_summaries(summaries, instance_id)


if __name__ == "__main__":
    main()
