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

from io import StringIO
from model import GameResult, ResultType, SingleGameTeamRecord
from re import compile, search
from typing import Sequence


class InvalidInputError(Exception):

    def __init__(self, message_template: str, game_result: str) -> None:
        Exception.__init__(self, message_template.format(game_result, game_result=game_result))

    @staticmethod
    def raise_syntactic_error(game_result: str) -> None:
        message_template = 'Invalid game result (syntactic error): "{game_result}".'
        raise InvalidInputError(message_template, game_result)

    @staticmethod
    def raise_semantic_error(game_result: str) -> None:
        message_template = 'Invalid game result (semantic error): "{game_result}".'
        raise InvalidInputError(message_template, game_result)


def _extract_team_record(match, team_re_group: int, goals_re_group: int) -> SingleGameTeamRecord:
    team = match.group(team_re_group)
    goals = int(match.group(goals_re_group))
    return SingleGameTeamRecord(team, goals)


def _extract_result_type(match, line: str) -> ResultType:
    result = ResultType.REGULATION
    suffix = match.group(6)
    try:
        if suffix:
            result = ResultType.from_abbreviation(suffix)
        return result
    except ValueError:
        InvalidInputError.raise_syntactic_error(line)



def _validate(game_result: GameResult, line: str) -> None:
    if game_result.home_team == game_result.visitor_team:
        InvalidInputError.raise_semantic_error(line)

    if game_result.home_team_goals == game_result.visitor_team_goals:
        InvalidInputError.raise_semantic_error(line)

    if game_result.type in [ResultType.OVERTIME, ResultType.SHOOTOUT]:
        difference = abs(game_result.home_team_goals - game_result.visitor_team_goals)
        if difference > 1:
            InvalidInputError.raise_semantic_error(line)


def read_single_line(line: str) -> GameResult:
    pattern = compile('^([A-Z]{3})-([A-Z]{3}) (\d+):(\d+)( (OT|SO))?$')
    match = pattern.match(line.strip())
    if match is None:
        InvalidInputError.raise_syntactic_error(line)
    game_result = GameResult(
        _extract_team_record(match, 1, 3),
        _extract_team_record(match, 2, 4),
        _extract_result_type(match, line)
    )
    _validate(game_result, line)
    return game_result


def read_all_lines(lines: str) -> Sequence[GameResult]:
    with StringIO(lines.strip()) as input:
        return [read_single_line(single_line) for single_line in input.readlines()]
