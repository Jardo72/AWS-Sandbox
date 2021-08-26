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
from boto3 import resource
from enum import Enum, unique


@unique
class Action(Enum):
    SETUP = 1
    CLEANUP = 2

    def __str__(self) -> str:
        return self.name.lower()

    def __repr__(self) -> str:
        return str(self)

    @staticmethod
    def argparse(str_value):
        try:
            return Action[str_value.upper()]
        except KeyError:
            return str_value


def create_command_line_arguments_parser() -> ArgumentParser:
    parser = ArgumentParser(description='S3 Event Notification Setup/Cleanup', formatter_class=RawTextHelpFormatter)
    parser.add_argument('lambda_arn', help='ARN of the Lambda function serving as event handler for the S3 event notification')
    parser.add_argument('bucket_name', help='name of the S3 bucket for which the S3 event notification is to be configured/deleted')
    parser.add_argument('action', type=Action.argparse, choices=list(Action))
    return parser


def parse_command_line_arguments():
    parser = create_command_line_arguments_parser()
    return parser.parse_args()


def create_s3():
    s3 = resource('s3')
    print('S3 resource created...')
    return s3


def setup_notification(lambda_arn: str, bucket_name: str) -> None:
    s3 = create_s3()
    print(f'Going to setup notification, Lambda ARN = {lambda_arn}, bucket name = {bucket_name}...')
    bucket_notification = s3.BucketNotification(bucket_name)
    response = bucket_notification.put(
        NotificationConfiguration={
            'LambdaFunctionConfigurations': [
                {
                    'LambdaFunctionArn': lambda_arn,
                    'Events': [
                        's3:ObjectCreated:*'
                    ]
                }
            ]
        }
    )
    print(f'Put request completed, response = {response}')


def cleanup_notification(bucket_name: str) -> None:
    s3 = create_s3()
    print(f'Going to cleanup notification, bucket name = {bucket_name}...')
    bucket_notification = s3.BucketNotification(bucket_name)
    response = bucket_notification.put(
        NotificationConfiguration={}
    )
    print(f'Delete request completed, response = {response}')


def main() -> None:
    params = parse_command_line_arguments()
    if params.action == Action.SETUP:
        setup_notification(params.lambda_arn, params.bucket_name)
    elif params.action == Action.CLEANUP:
        cleanup_notification(params.bucket_name)


if __name__ == '__main__':
    main()
