#
# Copyright 2021 Jaroslav Chmurny
#
# This file is part of AWS Sandbox.
#
# AWS Sandbox is free software developed for educational purposes. It
# is licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicationlicationlicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from json import dumps
from os import environ
from uuid import uuid4


instance_id = str(uuid4())
incovation_counter = 0


def main(event, context):
    global incovation_counter
    incovation_counter += 1

    body = {
        'functionInstance': {
            'name': context.function_name,
            'version': context.function_version,
            'instanceId': instance_id,
            'numberOfInvocations': incovation_counter,,
            'colorEnvVar': environ['COLOR']
        },
        'inputEvent': event
    }

    return {
        'statusCode': 200,
        'statusDescription': 'OK',
        'isBase64Encoded': False,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': dumps(body)
    }
