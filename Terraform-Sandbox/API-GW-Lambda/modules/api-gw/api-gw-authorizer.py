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

from base64 import standard_b64decode
from os import environ
from re import fullmatch


class MalformedCredendtials(Exception):

    def __init__(self, *args: object) -> None:
        super().__init__(*args)


def extract_username_password(authorization):
    m = fullmatch(r"Basic\s+([a-zA-Z0-9]+)", authorization)
    try:
        credentials = standard_b64decode(m.group(1))
        credentials = credentials.decode("utf-8")
        tokens = credentials.split(":")
        return (tokens[0], tokens[1])
    except:
        raise MalformedCredendtials("Unable to extract username/password from Authorization header.")


def main(event, context):
    print(f"Request to authorize request, event = {event}")

    api_gw_arn = environ["API_GW_ARN"]
    print(f"API GW stage ARN = {api_gw_arn}")
    
    authorization = event["headers"]["Authorization"]
    principal = "Unknown"
    effect = "Deny"

    try:
        if authorization:
            username, password = extract_username_password(authorization)
            principal = username
            if len(password) > len(username) and password > username:
                effect = "Allow"
    except MalformedCredendtials:
        ...

    return {
        "principalId": principal,
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
                    "Effect": effect
                }
            ]
        }
    }
