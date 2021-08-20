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

    @property
    def difference(self) -> int:
        return self.goals_for - self.goals_against

    @property
    def ratio(self) -> float:
        return self.goals_for / self.goals_against


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
    def regulation_win_count(self) -> int:
        return self.game_statistics.regulation_win_count

    @property
    def overtime_win_count(self) -> int:
        return self.game_statistics.overtime_win_count

    @property
    def overtime_loss_count(self) -> int:
        return self.game_statistics.overtime_loss_count

    @property
    def regulation_loss_count(self) -> int:
        return self.game_statistics.regulation_loss_count

    @property
    def goals_for(self) -> int:
        return self.score.goals_for

    @property
    def goals_against(self) -> int:
        return self.score.goals_against

    @property
    def score_difference(self) -> int:
        return self.score.difference

    @property
    def score_ratio(self) -> float:
        return self.score.ratio

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, StandingsEntry):
            return False
        if self.points != other.points:
            return False
        if self.score_difference != other.score_difference:
            return False
        if self.score_ratio != other.score_ratio:
            return False
        return True


    def __lt__(self, other: StandingsEntry) -> bool:
        if self.points < other.points:
            return True
        elif self.points > other.points:
            return False

        if self.score_difference < other.score_difference:
            return True
        elif self.score_difference > other.score_difference:
            return False

        if self.score_ratio < other.score_ratio:
            return True

        return False

    def __gt__(self, other: StandingsEntry) -> bool:
        if self.points > other.points:
            return True
        elif self.points < other.points:
            return False

        if self.score_difference > other.score_difference:
            return True
        elif self.score_difference < other.score_difference:
            return False

        if self.score_ratio > other.score_ratio:
            return True

        return False
