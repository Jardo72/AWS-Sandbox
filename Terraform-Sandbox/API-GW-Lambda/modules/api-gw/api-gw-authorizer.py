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

from os import environ


def main(event, context):
    print(f"Request to authorize request, event = {event}")

    api_gw_arn = environ["API_GW_ARN"]
    print(f"API GW stage ARN = {api_gw_arn}")
    
    return {
        "principalId": "abc123",
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Resource": [
                        f"{api_gw_arn}/GET/ssm/parameter",
                        f"{api_gw_arn}/POST/kms/encrypt",
                        f"{api_gw_arn}/POST/kms/decrypt",
                    ],
                    "Effect": "Allow"
                }
            ]
        }
    }
