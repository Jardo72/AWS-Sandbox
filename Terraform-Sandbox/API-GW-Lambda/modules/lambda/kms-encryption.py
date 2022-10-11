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

from base64 import standard_b64decode, standard_b64encode
from boto3 import client
from json import dumps, loads


kms_client = client("kms")
print('KMS client initialized')


def extract_from_json_body(event, attr1, attr2):
    json_data = loads(event['body'])
    return (json_data[attr1], json_data[attr2])


def convert_to_base64(text):
    text_as_bytes = text.encode("ascii")
    return standard_b64encode(text_as_bytes)


def encrypt(key_id, plaintext):
    response = kms_client.encrypt(
        KeyId=key_id,
        Plaintext=convert_to_base64(plaintext)
    )
    print(f'Encryption response = {response}')
    base64_bytes = standard_b64encode(response['CiphertextBlob'])
    return base64_bytes.decode('ascii')


def decrypt(key_id, ciphertext):
    response = kms_client.decrypt(
        KeyId=key_id,
        CiphertextBlob=standard_b64decode(ciphertext)
    )
    print(f'Decryption response = {response}')
    plaintext_bytes = response['Plaintext']
    plaintext_bytes = standard_b64decode(plaintext_bytes.decode('ascii'))
    return plaintext_bytes.decode('ascii')


def create_success_response(kms_key_id, plaintext, ciphertext):
    return {
        'statusCode': 200,
        'isBase64Encoded': False,
        'body': dumps({
            'kmsKeyId': kms_key_id,
            'plaintext': plaintext,
            'ciphertext': ciphertext
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


def encrypt_main(event, context):
    print(f'Encryption requested - event = {event}')
    try:
        kms_key_id, plaintext = extract_from_json_body(event, 'kmsKeyId', 'plaintext')
        ciphertext = encrypt(kms_key_id, plaintext)
        return create_success_response(kms_key_id, plaintext, ciphertext)
    except kms_client.exceptions.NotFoundException as e:
        print(str(e))
        return create_error_response(404, e)
    except KeyError:
        print(str(e))
        return create_error_response(e)


def decrypt_main(event, context):
    print(f'Decryption requested - event = {event}')
    try:
        kms_key_id, ciphertext = extract_from_json_body(event, 'kmsKeyId', 'ciphertext')
        plaintext = decrypt(kms_key_id, ciphertext)
        return create_success_response(kms_key_id, plaintext, ciphertext)
    except kms_client.exceptions.NotFoundException as e:
        print(str(e))
        return create_error_response(404, e)
    except (KeyError, kms_client.exceptions.InvalidCiphertextException) as e:
        print(str(e))
        return create_error_response(400, e)
