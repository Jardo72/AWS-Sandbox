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
from urllib.parse import unquote_plus

from input import read_all_lines
from model import ResultType, StandingsEntry
from output import print_standings
from standings import Configuration, StandingsCalculator


class _LambdaConfiguration(Configuration):

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


configuration = _LambdaConfiguration()
sqs_client = client('sqs')
s3_client = client('s3')


def _extract_file_properties(record):
    bucket_name = record['s3']['bucket']['name']
    object_key = unquote_plus(record['s3']['object']['key'], encoding='utf-8')
    return (bucket_name, object_key)


def _read_game_results(bucket_name, object_key):
    print(f'Processing file with game results - bucket = "{bucket_name}", object key = "{object_key}"')
    object = s3_client.get_object(Bucket=bucket_name, Key=object_key)
    data = object["Body"].read()
    data = data.decode('utf-8')
    return read_all_lines(data)


def _calculate_standings(game_results):
    calculator = StandingsCalculator(configuration)
    calculator.add_all(game_results)
    return calculator.calculate_standings()


def _send_message(message_body, bucket_name, object_key):
    queue_url = environ['STANDINGS_QUEUE']
    response = sqs_client.send_message(
        QueueUrl=queue_url,
        MessageGroupId='hockey-game-results',
        MessageAttributes={
            'Bucket': {
                'DataType': 'String',
                'StringValue': bucket_name
            },
            'Filename': {
                'DataType': 'String',
                'StringValue': object_key
            }
        },
        MessageBody=message_body
    )
    print(f'Standings sent to SQS queue {queue_url}, message ID = {response["MessageId"]}')


def _process_single_file(record):
    bucket_name, object_key = _extract_file_properties(record)
    game_results = _read_game_results(bucket_name, object_key)
    standings = _calculate_standings(game_results)
    output = print_standings(standings)
    _send_message(output, bucket_name, object_key)


def main(event, context):
    for record in event['Records']:
        _process_single_file(record)
    return True
