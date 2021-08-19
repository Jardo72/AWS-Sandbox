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

from model import StandingsEntry


def _column_headings() -> str:
    return '          GP RW OW OL RL GF:GA PTS'


def _legend() -> str:
    return
"""
Legend
GP .... Games Played
RW .... Regulation Wins
OW .... Overtime + Shootout Wins
RL .... Regulation Losses
OL .... Overtime + Shootout Losses
GF .... Goals For
GF .... Goals Against
PTS ... Points
"""
