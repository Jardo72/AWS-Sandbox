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
from random import randint
from sys import argv
from time import sleep
from typing import Sequence, Tuple
from uuid import uuid4

from boto3 import client


@dataclass(frozen=True)
class Sample:
    timestamp: datetime
    value: int
    status_code: int


@dataclass(frozen=True)
class Summary:
    number_of_samples: int
    min_value: int
    max_value: int
    avg_value: float


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
    for _ in range(0, number_of_samples):
        sample = publish_single_sample(cloud_watch, instance_id)
        samples.append(sample)
        sleep(period_sec)
    return tuple(samples)


def calculate_summary(samples: Sequence[Sample]) -> Summary:
    number_of_samples = len(samples)
    values = map(lambda i: i.value, samples)
    avg_value = sum(values) / number_of_samples
    min_value = min(values)
    max_value = max(values)
    return Summary(number_of_samples, min_value, max_value, avg_value)


def main():
    period_sec = int(argv[1])
    number_of_samples = int(argv[2])
    instance_id = str(uuid4())

    print()
    print(f'InstanceId = {instance_id}')
    print(f'{number_of_samples} samples to be generated, period = {period_sec} sec')
    print()

    samples = publish_samples(number_of_samples, period_sec, instance_id)
    summary = calculate_summary(samples)
    print(summary)


# https://stackify.com/custom-metrics-aws-lambda/
if __name__ == "__main__":
    main()
