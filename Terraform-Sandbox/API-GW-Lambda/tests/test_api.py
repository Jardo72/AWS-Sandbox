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

from dataclasses import dataclass
from urllib import response
from pytest import mark

import requests


HOSTNAME = "xwhwsybzm5.execute-api.eu-central-1.amazonaws.com/sandbox"
KMS_KEY_ID = "a48a7295-7b9a-421a-9ba0-c6a78e39f873"

@dataclass(frozen=True)
class TestCaseData:
    name: str
    expected_value: str


class TestSsmParamaterReading:
    
    @mark.parametrize("test_case_data", [
        TestCaseData(name="/api-gw-lambda-samples/sample-param-one", expected_value="Sample SSM value #1 for API-GW-Lambda-Demo"),
        TestCaseData(name="/api-gw-lambda-samples/sample-param-two", expected_value="Sample SSM value #2 for API-GW-Lambda-Demo"),
        TestCaseData(name="/api-gw-lambda-samples/sample-param-three", expected_value="Sample SSM value #3 for API-GW-Lambda-Demo"),
    ])
    def test_that_proper_param_value_is_read(self, test_case_data: TestCaseData) -> None:
        url = f"https://{HOSTNAME}/ssm-parameter"
        response = requests.get(url)

        assert response.status_code == 200

        json_payload = response.json()
        assert json_payload["name"] == test_case_data.name
        assert json_payload["type"] == "String"
        assert json_payload["value"] == test_case_data.expected_value


class KmsEncryptionDecryption:

    def test_that_() -> None:
        encryption_url = f"https://{HOSTNAME}/kms/encrypt"
        encryption_response = requests.post(encryption_url, data={
            "plaintext": "Hello world!!!",
            "kmsKeyId": KMS_KEY_ID
        })

        assert encryption_response.status_code == 200
        ciphertext = encryption_response.json["ciphertext"]

        decryption_url = f"https://{HOSTNAME}/kms/decrypt"
        decryption_response = requests.post(decryption_url, data={
            "ciphertext": ciphertext,
            "kmsKeyId": KMS_KEY_ID
        })

        assert decryption_response.status_code == 200
        plaintext = decryption_response.json()["plaintext"]
