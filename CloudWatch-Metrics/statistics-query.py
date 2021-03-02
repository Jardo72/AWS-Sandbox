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

from datetime import datetime
from sys import argv

from boto3 import resource


def main() -> None:
    cloud_watch = resource('cloudwatch')
    metric = cloud_watch.Metric('JCH', 'RandomValue')
    dimensions = [{'Name': 'InstanceId', 'Value': '5fc4d4ce-7a80-4830-b82e-b869f972fc73'}]
    statistics = metric.get_statistics(
        Dimensions=dimensions,
        StartTime=datetime(2021, 3, 2),
        EndTime=datetime(2021, 3, 3),
        Statistics=['SampleCount', 'Minimum', 'Maximum', 'Average'],
        Period=24 * 60 * 60,
        Unit='None')
    print(statistics)


if __name__ == "__main__":
    main()
