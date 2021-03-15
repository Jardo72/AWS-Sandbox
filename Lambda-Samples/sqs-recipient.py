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

from uuid import uuid4


instance_id = str(uuid4())
invocation_counter = 0
message_counter = 0


def main(event, context):
    global invocation_counter, message_counter

    invocation_counter += 1
    message_counter += len(event['Records'])
    print(f'Statistics (totals): {invocation_counter} invocations, {message_counter} messages consumed')

    payloads = []
    for single_message in event['Records']:
        payloads.append(single_message['body'])
    print(payloads)
    return True
