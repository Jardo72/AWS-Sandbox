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

from dataclasses import dataclass
from json import load, loads
from typing import List, Optional, Sequence, Tuple

@dataclass(frozen=True)
class LineItineraryItem:
    station: str
    point_in_time: int


@dataclass(frozen=True)
class Line:
    identifier: str
    means_of_transport: str
    itinerary: Tuple[LineItineraryItem, ...]


@dataclass(frozen=True)
class ModelDefinition:
    version: str
    lines: Tuple[Line, ...]


@dataclass(frozen=True)
class _Config:
    bucket: Optional[str]
    path: str


def _read_single_itinerary(json_data) -> Tuple[LineItineraryItem, ...]:
    result = []
    for element in json_data:
        station = element['station']
        point_in_time = element['pointInTime']
        result.append(LineItineraryItem(station, point_in_time))
    return tuple(result)


def _read_single_line(json_data) -> Line:
    identifier = json_data['identifier']
    means_of_transport = json_data['meansOfTransport']
    itinerary = _read_single_itinerary(json_data['itinerary'])
    return Line(identifier, means_of_transport, itinerary)


def _read_from_string(json_string: str) -> ModelDefinition:
    lines: List[Line] = []
    json_data = loads(json_string)
    version = json_data['version']
    for element in json_data['lines']:
        line = _read_single_line(element)
        lines.append(line)
    return ModelDefinition(version, tuple(lines))


def _read_model_from_file(filename: str) -> ModelDefinition:
    with open(filename) as json_file:
        json_string = "".join(line.rstrip() for line in json_file)
        return _read_from_string(json_string)

def _read_model_from_s3(bucket_name: str, object_key: str) -> ModelDefinition:
    import boto3

    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
    json_string = bucket.Object(object_key).get()['Body'].read()
    return _read_from_string(json_string)


def _read_config(config_file: str) -> _Config:
    if config_file is None or len(config_file) == 0:
        raise Exception()
    with open(config_file) as json_file:
        json_data = load(json_file)
    bucket = json_data['bucket'] if 'bucket' in json_data and json_data['bucket'] else None
    return _Config(bucket, json_data['path'])


def read(config_file: str) -> ModelDefinition:
    config = _read_config(config_file)
    if config.bucket is None:
        return _read_model_from_file(config.path)
    return _read_model_from_s3(config.bucket, config.path)
