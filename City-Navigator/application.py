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

from flask import Flask, jsonify, request

from definition import read
from model import Model
from service import LineDetails, LineDirectionDetails, JourneyLeg, JourneyPlan, Service, Station, StatisticsSnapshot
from sys import argv
from typing import Any, Dict


config_file = None if len(argv) < 2 else argv[1]
model = Model(read(config_file))
service = Service(model)

application = app = Flask(__name__)


def _map_station(station: Station) -> Dict[str, Any]:
    return {
        'station': station.name,
        'pointInTime': station.point_in_time
    }


def _map_line_direction(direction: LineDirectionDetails) -> Dict[str, Any]:
    return {
        'terminalStop': direction.destination,
        'itinerary': [_map_station(station) for station in direction.itinerary]
    }


def _map_line_details(line: LineDetails) -> Dict[str, Any]:
    return {
        'identifier': line.identifier,
        'directionOne': _map_line_direction(line.direction_one),
        'directionTwo': _map_line_direction(line.direction_two)
    }


def _map_journey_leg(journey_leg: JourneyLeg) -> Dict[str, Any]:
    return {
        'start': journey_leg.start,
        'destination': journey_leg.destination,
        'meansOfTransport': journey_leg.means_of_transport,
        'line': journey_leg.line,
        'stopCount': journey_leg.stop_count,
        'durationMinutes': journey_leg.duration_minutes
    }


def _map_statistics_snapshot(snapshot: StatisticsSnapshot) -> Dict[str, Any]:
    if (snapshot.request_count == 0):
        return {
            'requestCount': snapshot.request_count,
        }
    return {
        'requestCount': snapshot.request_count,
        'avgRequestDurationMillis': snapshot.avg_request_duration_millis,
        'minRequestDurationMillis': snapshot.min_request_duration_millis,
        'maxRequestDurationMillis': snapshot.max_request_duration_millis
    }


def _map_journey_plan(journey_plan: JourneyPlan) -> Dict[str, Any]:
    return {
        'start': journey_plan.start,
        'destination': journey_plan.destination,
        'legs': [_map_journey_leg(leg) for leg in journey_plan.legs]
    }


@app.route('/version')
def get_version():
    return {
        'application': '1.0',
        'model': service.model_version
    }

@app.route('/means-of-transport', methods=['GET'])
def get_means_of_transport():
    return jsonify(service.get_means_of_transport())


@app.route('/lines', methods=['GET'])
def get_all_lines():
    return jsonify(service.get_all_lines())


@app.route('/lines/<means_of_transport>', methods=['GET'])
def get_lines_by_means_of_transport(means_of_transport: str):
    return jsonify(service.get_lines(means_of_transport))


@app.route('/line/<identifier>', methods=['GET'])
def get_line(identifier: str):
    line = service.get_line_details(identifier)
    return _map_line_details(line)


@app.route('/journey-plan', methods=['GET'])
def calculate_journey_plan():
    start = request.args.get('start')
    if start is None or len(start) == 0:
        return 'Mandatory start parameter is undefined!', 400

    destination = request.args.get('destination')
    if destination is None or len(destination) == 0:
        return 'Mandatory destination parameter is undefined!', 400

    journey_plan = service.calculate_journey_plan(start, destination)
    return _map_journey_plan(journey_plan)


@app.route('/calculation-statistics', methods=['GET'])
def get_calculation_statistics():
    snapshot = service.get_calculation_statistics()
    return _map_statistics_snapshot(snapshot)


app.run(port=80, debug=True)

# deployment to Beanstalk
# https://www.youtube.com/watch?v=P5kGTr2zfn4

# reading from S3
# https://stackoverflow.com/questions/36205481/read-file-content-from-s3-bucket-with-boto3

# Flask & REST API
# https://blog.miguelgrinberg.com/post/designing-a-restful-api-using-flask-restful

