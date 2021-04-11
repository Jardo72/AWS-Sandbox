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

from dataclasses import dataclass
from datetime import datetime
from typing import Sequence


class Constants:
    
    @staticmethod
    def namespace() -> str:
        return  'JCH'

    @staticmethod
    def metric() -> str:
        return 'RandomValue'

    @staticmethod
    def metric_from_log() -> str:
        return 'RandomValueFromLog'

    @staticmethod
    def timestamp_format() -> str:
        return '%Y-%m-%dT%H:%M:%SZ'

    @staticmethod
    def log_group_name():
        return 'CloudWatch-Metrics-Demo'


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
    min_timestamp = summary.min_timestamp.strftime(Constants.timestamp_format())
    max_timestamp = summary.max_timestamp.strftime(Constants.timestamp_format())
    print()
    print(f'Relevant values (status code 200): {summary.number_of_values}')
    print(f'Instance ID:    {instance_id}')
    print(f'Min value:      {summary.min_value}')
    print(f'Max value:      {summary.max_value}')
    print(f'Avg value:      {summary.avg_value}')
    print(f'Min timestamp:  {min_timestamp}')
    print(f'Max timestamp:  {max_timestamp}')
