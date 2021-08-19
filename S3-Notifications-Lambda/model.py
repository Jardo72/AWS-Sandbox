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

# for Python 3.8, this is needed if a static method wants to declare
# its own class as return type
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum, unique


@unique
class ResultType(Enum):
    REGULATION = 1
    OVERTIME = 2
    SHOOTOUT = 3

    @staticmethod
    def from_abbreviation(abbreviation: str) -> ResultType:
        if abbreviation == 'SO':
            return ResultType.SHOOTOUT
        elif abbreviation == 'OT':
            return ResultType.OVERTIME

        message = f'Unexpected abbreviation "{abbreviation}" - cannot resolve result type.'
        raise ValueError(message)


@dataclass(frozen=True)
class SingleGameTeamRecord:
    team: str
    goals: int


@dataclass(frozen=True)
class GameResult:
    home_team_record: SingleGameTeamRecord
    visitor_team_record: SingleGameTeamRecord
    type: ResultType

    @property
    def home_team(self) -> str:
        return self.home_team_record.team

    @property
    def home_team_goals(self) -> int:
        return self.home_team_record.goals

    @property
    def visitor_team(self) -> str:
        return self.visitor_team_record.team

    @property
    def visitor_team_goals(self) -> int:
        return self.visitor_team_record.goals


@dataclass(frozen=True)
class GameStatistics:
    regulation_win_count: int
    overtime_win_count: int
    overtime_loss_count: int
    regulation_loss_count: int

    @property
    def overall_game_count(self) -> int:
        return self.regulation_win_count + self.overtime_win_count + self.regulation_loss_count + self.overtime_loss_count


@dataclass(frozen=True)
class Score:
    goals_for: int
    goals_against: int


@dataclass(frozen=True)
class StandingsEntry:
    team: str
    game_statistics: GameStatistics
    score: Score
    points: int

    @property
    def overall_game_count(self) -> int:
        return self.game_statistics.overall_game_count

    @property
    def goals_for(self) -> int:
        return self.score.goals_for

    @property
    def goals_against(self) -> int:
        return self.score.goals_against
