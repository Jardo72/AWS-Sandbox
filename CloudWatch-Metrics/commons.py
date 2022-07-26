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

from dataclasses import dataclass
from datetime import datetime
from time import time
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
    def metrics_log_group_name() -> str:
        return 'CloudWatch-Logs-For-Metrics'

    def insights_log_group_name() -> str:
        return 'CloudWatch-Logs-For-Insights'


@dataclass(frozen=True)
class Sample:
    timestamp: datetime
    value: int
    status_code: int


@dataclass(frozen=True)
class MetricDataSummary:
    number_of_values: int
    min_value: int
    max_value: int
    avg_value: float
    min_timestamp: datetime
    max_timestamp: datetime


@dataclass(frozen=True)
class LogEventsSummary:
    log_stream_name: str
    start_timestamp: str
    end_timestamp: str
    number_of_log_events: int


def calculate_summary(samples: Sequence[Sample]) -> MetricDataSummary:
    relevant_samples = filter(lambda s: s.status_code == 200, samples)
    relevant_samples = list(relevant_samples)
    values = list(map(lambda s: s.value, relevant_samples))
    number_of_values = len(values)
    avg_value = sum(values) / number_of_values
    min_value = min(values)
    max_value = max(values)
    start_time = relevant_samples[0].timestamp
    end_time = relevant_samples[-1].timestamp
    return MetricDataSummary(number_of_values, min_value, max_value, avg_value, start_time, end_time)


def print_summary(instance_id: str, summary: MetricDataSummary) -> None:
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


def current_timestamp() -> str:
    return datetime.utcnow().strftime(Constants.timestamp_format())


def current_time_millis() -> int:
    return int(time() * 1000)


def create_log_stream(cloud_watch, log_group_name: str, log_stream_name: str) -> None:
    try:
        cloud_watch.create_log_group(logGroupName=log_group_name)
    except Exception:
        # chances are the log group already exists - we do not want to fail in such a case
        pass
    cloud_watch.create_log_stream(logGroupName=log_group_name, logStreamName=log_stream_name)
    print(f'Log stream created (name = {log_stream_name}, log group = {log_group_name})')
