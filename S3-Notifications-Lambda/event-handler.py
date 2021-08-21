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


from boto3 import client
from os import environ

from model import ResultType, StandingsEntry
from output import print_standings
from standings import Configuration


class LambdaConfiguration(Configuration):

    def __init__(self) -> None:
        self._regulation_win_points = int(environ['REGULATION_WIN_POINTS'])
        self._overtime_win_points = int(environ['OVERTIME_WIN_POINTS'])
        self._shootout_win_points = int(environ['SHOOTOUT_WIN_POINTS'])
        self._regulation_loss_points = int(environ['REGULATION_LOSS_POINTS'])
        self._overtime_loss_points = int(environ['OVERTIME_LOSS_POINTS'])
        self._shootout_loss_points = int(environ['SHOOTOUT_LOSS_POINTS'])

    def get_points_for_win(self, result_type: ResultType) -> int:
        if result_type == ResultType.REGULATION:
            return self._regulation_win_points
        elif result_type == ResultType.OVERTIME:
            return self._overtime_win_points
        elif result_type == ResultType.SHOOTOUT:
            return self._shootout_win_points
        raise ValueError(f'Unexpected result type: {result_type}.')

    def get_points_for_loss(self, result_type: ResultType) -> int:
        if result_type == ResultType.REGULATION:
            return self._regulation_loss_points
        elif result_type == ResultType.OVERTIME:
            return self._overtime_loss_points
        elif result_type == ResultType.SHOOTOUT:
            return self._shootout_loss_points
        raise ValueError(f'Unexpected result type: {result_type}.')


def process_single_file(record):
    bucket = record['s3']['bucket']['name']
    filename = record['s3']['object']['key']
    print(f'Processing file: bucket = "{bucket}", filename = "{filename}"')

# https://stackoverflow.com/questions/46928105/reading-files-triggered-by-s3-event
def main(event, context):
    print('S3 notification event handler invoked, look at the event')
    print(event)

    configuration = LambdaConfiguration()
    # s3_client = client('s3')
    for record in event['Records']:
        process_single_file(record)
    return 'Done :-)'