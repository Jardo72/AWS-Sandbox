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

from typing import Sequence

from model import StandingsEntry


def _column_headings() -> str:
    return '          GP RW OW OL RL GF:GA PTS\n'


def _standings_entries(entries: Sequence[StandingsEntry]) -> str:
    result = ''
    for index, single_entry in enumerate(entries):
        rank = index + 1
        result += f'{rank:2}.{single_entry.team}'
        result += f'    {single_entry.overall_game_count:2d}'
        result += f' {single_entry.regulation_win_count:2d}'
        result += f' {single_entry.overtime_win_count:2d}'
        result += f' {single_entry.overtime_loss_count:2d}'
        result += f' {single_entry.regulation_loss_count:2d}'
        result += f' {single_entry.goals_for:2d}'
        result += f':{single_entry.goals_against:2d}'
        result += f' {single_entry.points:3d}'
        result += '\n'
    return result


def _legend() -> str:
    return """
Legend
GP .... Games Played
RW .... Regulation Wins
OW .... Overtime + Shootout Wins
OL .... Overtime + Shootout Losses
RL .... Regulation Losses
GF .... Goals For
GF .... Goals Against
PTS ... Points
"""


def print_standings(entries: Sequence[StandingsEntry]) -> str:
    return _column_headings() + _standings_entries(entries) + _legend()
