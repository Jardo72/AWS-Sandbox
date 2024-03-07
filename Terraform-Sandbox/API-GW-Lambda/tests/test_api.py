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
from json import dumps
from os import environ
from pytest import mark

import requests


API_GW_INVOCATION_URL = environ.get("API_GW_DEMO_INVOCATION_URL")
KMS_KEY_ID = environ.get("API_GW_DEMO_KMS_KEY_ID", default="a48a7295-7b9a-421a-9ba0-c6a78e39f873")


@dataclass(frozen=True)
class Params:
    param_name: str
    expected_value: str


class TestSsmParamaterReading:
    
    @mark.parametrize("test_case_data", [
        Params(param_name="/api-gw-lambda-samples/sample-param-one", expected_value="Sample SSM parameter value #1 for API-GW-Lambda-Demo"),
        Params(param_name="/api-gw-lambda-samples/sample-param-two", expected_value="Second SSM parameter value for API-GW-Lambda-Demo"),
        Params(param_name="/api-gw-lambda-samples/sample-param-three", expected_value="Dummy SSM parameter value #3 for API-GW-Lambda-Demo"),
    ])
    def test_that_proper_param_value_is_read(self, test_case_data: Params) -> None:
        response = requests.get(
            f"{API_GW_INVOCATION_URL}/ssm/parameter",
            params={"name": test_case_data.param_name}
        )

        assert response.status_code == 200

        json_payload = response.json()
        assert json_payload["name"] == test_case_data.param_name
        assert json_payload["type"] == "String"
        assert json_payload["value"] == test_case_data.expected_value


class TestKmsEncryptionDecryption:

    @mark.parametrize("plaintext", [
        "Dummy plaintext for test purposes",
        "It's hopeless, but I do not take it seriously :-)",
        "I do not believe this text will be properly encrypted/decrypted",
        "What about some numbers, like 1, 2, 4, 8, 16, 32, ...",
        "Can it encrypt some special characters like #, $, (, ), @, +, -, *, /, &, ~?"
    ])
    def test_that_encyption_followed_by_decryption_leads_to_original_plaintext(self, plaintext: str) -> None:
        encryption_request_body = {
            "plaintext": plaintext,
            "kmsKeyId": KMS_KEY_ID
        }
        encryption_response = requests.post(
            f"{API_GW_INVOCATION_URL}/kms/encrypt",
            data=dumps(encryption_request_body)
        )

        assert encryption_response.status_code == 200
        encryption_response_body = encryption_response.json()
        assert plaintext == encryption_response_body["plaintext"]
        ciphertext = encryption_response_body["ciphertext"]

        decryption_request_body = {
            "ciphertext": ciphertext,
            "kmsKeyId": KMS_KEY_ID
        }
        decryption_response = requests.post(
            f"{API_GW_INVOCATION_URL}/kms/decrypt",
            data=dumps(decryption_request_body)
        )

        assert decryption_response.status_code == 200
        decryption_response_body = decryption_response.json()
        assert ciphertext == decryption_response_body["ciphertext"]
        assert plaintext == decryption_response_body["plaintext"]

    def test_that_encryption_with_non_existent_key_leads_to_error(self) -> None:
        encryption_request_body = {
            "plaintext": "Text not relevant",
            "kmsKeyId": "00000000-0001-0001-0001-111111111111"
        }
        encryption_response = requests.post(
            f"{API_GW_INVOCATION_URL}/kms/encrypt",
            data=dumps(encryption_request_body)
        )

        assert encryption_response.status_code == 404
