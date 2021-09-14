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


start_time = datetime.utcnow()
application = Flask(__name__)


@application.route('/version')
def get_version():
    print('Request received: /version')
    return {
        'application': 'V1',
        'python': version
    }


@application.route('/hostname')
def get_hostname():
    print('Request received: /hostname')
    return getfqdn()


@application.route('/start-time')
def get_start_time():
    print('Request received: /start-time')
    return date.strftime(start_time, 'Start time = %d-%b-%Y %H:%M:%S UTC')


@application.route('/environment-variables')
def get_environment_variables():
    print('Request received: /environment-variables')
    return {name: value for name, value in environ.items()}


@application.route('/consume-cpu')
def get_cpu_consumption():
    print('Request received: /consume-cpu')
    start_time = perf_counter()
    result = 1000000
    for i in range(1000000, 1000000000000):
        result *= i
        if i % 1000 == 0:
            sleep(0.01)
            execution_time = perf_counter() - start_time
            if execution_time >= 1:
                print(f'CPU consumed for {execution_time} sec')
                return


if __name__ == "__main__":
    start_time_str = date.strftime(start_time, '%d-%b-%Y %H:%M:%S UTC')
    print(f'Starting the application, start time = {start_time_str}')
    application.run(host='0.0.0.0', port=80, debug=True)
