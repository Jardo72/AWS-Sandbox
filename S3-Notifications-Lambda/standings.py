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

from abc import ABC, abstractmethod
from typing import Dict, Sequence

from model import GameResult, GameStatistics, ResultType, Score, StandingsEntry


class Configuration(ABC):

    @abstractmethod
    def get_points_for_win(self, result_type: ResultType) -> int:
        pass

    @abstractmethod
    def get_points_for_loss(self, result_type: ResultType) -> int:
        pass


class _StandingsEntryCollector:

    def __init__(self, team: str, configuration: Configuration) -> None:
        self._team = team
        self._configuration = configuration
        self._regulation_win_count = 0
        self._overtime_win_count = 0
        self._overtime_loss_count = 0
        self._regulation_loss_count = 0
        self._goals_against = 0
        self._goals_for = 0
        self._points = 0

    def add(self, game_result: GameResult) -> None:
        goals_against = 0
        goals_for = 0
        if self._team == game_result.home_team:
            goals_against = game_result.visitor_team_goals
            goals_for = game_result.home_team_goals
        elif self._team == game_result.visitor_team:
            goals_against = game_result.home_team_goals
            goals_for = game_result.visitor_team_goals
        else:
            message = f'Unexpected game result ({game_result.home_team} vs {game_result.visitor_team}), collecting results for {self._team}.'
            raise ValueError(message)
        self._add(goals_for, goals_against, game_result.type)

    def _add(self, goals_for: int, goals_against: int, result_type: ResultType) -> None:
        print(f'Adding {goals_for}:{goals_against} {result_type} to {self._team}')
        self._goals_against += goals_against
        self._goals_for += goals_for
        if goals_for > goals_against:
            self._points += self._configuration.get_points_for_win(result_type)
            if result_type == ResultType.REGULATION:
                self._regulation_win_count += 1
            else:
                self._overtime_win_count += 1
        else:
            self._points += self._configuration.get_points_for_loss(result_type)
            if result_type == ResultType.REGULATION:
                self._regulation_loss_count += 1
            else:
                self._overtime_loss_count += 1
        print(f'Updated points = {self._points}, updated score = {self._goals_for}:{self._goals_against}')

    @property
    def standings_entry(self) -> StandingsEntry:
        return StandingsEntry(
            self._team,
            GameStatistics(
                self._regulation_win_count,
                self._overtime_win_count,
                self._overtime_loss_count,
                self._regulation_loss_count
            ),
            Score(self._goals_for, self._goals_against),
            self._points
        )


class _StandingsCollector:

    def __init__(self, configuration: Configuration) -> None:
        self._teams: Dict[str, _StandingsEntryCollector] = {}
        self._configuration = configuration

    def add(self, game_result: GameResult) -> None:
        self._add(game_result.home_team, game_result)
        self._add(game_result.visitor_team, game_result)

    def _add(self, team: str, game_result: GameResult) -> None:
        if team not in self._teams:
            self._teams[team] = _StandingsEntryCollector(team, self._configuration)
        self._teams[team].add(game_result)

    @property
    def standings_entries(self) -> Sequence[StandingsEntry]:
        entries = self._teams.values()
        return list(map(lambda collector: collector.standings_entry, entries))


class StandingsCalculator:

    def __init__(self, configuration: Configuration) -> None:
        self._collector = _StandingsCollector(configuration)

    def add(self, game_result: GameResult) -> None:
        self._collector.add(game_result)

    def calculate_standings(self) -> Sequence[StandingsEntry]:
        return list(sorted(self._collector.standings_entries, reverse=True))


# TODO: remove
if __name__ == "__main__":
    print("Hello world")
