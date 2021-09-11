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
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from datetime import date, datetime
from flask import Flask
from os import environ
from socket import getfqdn
from sys import version


application = Flask(__name__)


@application.route('/version')
def get_version():
    return {
        'application': 'V1',
        'python': version
    }


@application.route('/hostname')
def get_hostname():
    return getfqdn()


@application.route('/start-time')
def get_start_time():
    return date.strftime(datetime.utcnow(), 'Start time = %d-%b-%Y %H:%M:%S UTC')


@application.route('/environment-variables')
def get_environment_variables():
    return {name: value for name, value in environ.items()}


if __name__ == "__main__":
    application.run(host='0.0.0.0', port=80, debug=True)
