#
# Copyright 2022 Jaroslav Chmurny
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

from boto3 import client
from json import dumps
from urllib.parse import unquote


ssm_client = client('ssm')
print('SSM client initialized')


def extract_query_string_param(event, param_name):
    url_encoded_value = event['queryStringParameters'][param_name]
    return unquote(url_encoded_value)


def create_success_response(param):
    return {
        'statusCode': 200,
        'isBase64Encoded': False,
        'body': dumps({
            'name': param['Parameter']['Name'],
            'type': param['Parameter']['Type'],
            'value': param['Parameter']['Value'],
            'version': param['Parameter']['Version']
        })
    }


def create_error_response(status_code, error):
    return {
        'statusCode': status_code,
        'isBase64Encoded': False,
        'body': dumps({
            'exception': error.__class__.__name__,
            'detail': str(error)
        })
    }


def main(event, context):
    print(f'Request to read SSM parameter, event = {event}')
    try:
        name = extract_query_string_param(event, 'name')
        param = ssm_client.get_parameter(Name=name)
        print(f'Parameter info retrieved, param = {param}')
        return create_success_response(param)
    except ssm_client.exceptions.ParameterNotFound as e:
        print(str(e))
        return create_error_response(404, e)
    except KeyError as e:
        print(str(e))
        create_error_response(400, e)
