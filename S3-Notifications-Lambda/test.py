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

from sys import argv

from input import read_single_line
from model import ResultType
from output import print_standings
from standings import Configuration, StandingsCalculator


class TestConfiguration(Configuration):

    def get_points_for_win(self, result_type: ResultType) -> int:
        if result_type == ResultType.REGULATION:
            return 3
        elif result_type in [ResultType.OVERTIME, ResultType.SHOOTOUT]:
            return 2
        raise ValueError(f'Unexpected result type: {result_type}.')

    def get_points_for_loss(self, result_type: ResultType) -> int:
        if result_type == ResultType.REGULATION:
            return 0
        elif result_type in [ResultType.OVERTIME, ResultType.SHOOTOUT]:
            return 1
        raise ValueError(f'Unexpected result type: {result_type}.')


def main():
    calculator = StandingsCalculator(TestConfiguration())
    with open(argv[1]) as input_file:
        for line in input_file.readlines():
            game_result = read_single_line(line)
            calculator.add(game_result)
    standings = calculator.calculate_standings()
    print(print_standings(standings))


if __name__ == "__main__":
    main()
