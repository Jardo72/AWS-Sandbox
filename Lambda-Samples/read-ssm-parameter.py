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

import boto3

def main(event, context):
    ssm_client = boto3.client('ssm', region_name=event['region'])
    param = ssm_client.get_parameter(Name=event['parameter'])
    return {
        'name': param['Parameter']['Name'],
        'type': param['Parameter']['Type'],
        'value': param['Parameter']['Value'],
        'version': param['Parameter']['Version'],
    }
