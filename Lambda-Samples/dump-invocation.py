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

from os import environ
from uuid import uuid4


instance_id = str(uuid4())
incovation_counter = 0


def main(event, context):
    global incovation_counter
    incovation_counter += 1

    return {
        'functionInstance': {
            'instanceId': instance_id,
            'numberOfInvocations': incovation_counter
        },
        'event': event,
        'context': {
            'functionName': context.function_name,
            'functionVersion': context.function_version,
            'memoryLimitMB': context.memory_limit_in_mb,
            'remainingTimeMillis': context.get_remaining_time_in_millis()
        },
        'environmentVariables': {name: value for name, value in environ.items()}
    }
