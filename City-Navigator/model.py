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

from dataclasses import dataclass
from typing import Dict, List, Tuple

from definition import Line, ModelDefinition


@dataclass(frozen=True)
class Station:
    name: str
    point_in_time: int


@dataclass(frozen=True)
class LineDirectionDetails:
    itinerary: Tuple[Station, ...]

    @property
    def start(self) -> str:
        return self.itinerary[0].name

    @property
    def destination(self) -> str:
        return self.itinerary[-1].name


@dataclass(frozen=True)
class LineDetails:
    means_of_transport: str
    identifier: str
    direction_one: LineDirectionDetails
    direction_two: LineDirectionDetails


class Model:

    def __init__(self, definition: ModelDefinition) -> None:
        self._means_of_transport: Dict[str, List[Line]] = {}
        self._version = definition.version
        self._lines: Dict[str, LineDetails] = {}
        for single_line in definition.lines:
            if single_line.means_of_transport not in self._means_of_transport:
                self._means_of_transport[single_line.means_of_transport] = []
            self._means_of_transport[single_line.means_of_transport].append(single_line)
            self._lines[single_line.identifier] = Model._create_line_details(single_line)

    @staticmethod
    def _create_line_details(line: Line) -> LineDetails:
        direction_one: List[Station] = list(map(lambda item: Station(item.station, item.point_in_time), line.itinerary))
        direction_two: List[Station] = []
        terminal_point_in_time = line.itinerary[-1].point_in_time
        for item in reversed(line.itinerary):
            point_in_time = terminal_point_in_time - item.point_in_time
            direction_two.append(Station(item.station, point_in_time))
        direction_one_details = LineDirectionDetails(tuple(direction_one))
        direction_two_details = LineDirectionDetails(tuple(direction_two))
        return LineDetails(line.means_of_transport, line.identifier, direction_one_details, direction_two_details)

    @property
    def version(self) -> str:
        return self._version

    def get_means_of_transport(self) -> Tuple[str, ...]:
        return tuple(self._means_of_transport.keys())

    def get_lines(self, means_of_transport: str) -> Tuple[str, ...]:
        if means_of_transport not in self._means_of_transport:
            return tuple()
        lines: List[Line] = self._means_of_transport[means_of_transport]
        return tuple(map(lambda single_line: single_line.identifier, lines))

    def get_all_lines(self) -> Tuple[str, ...]:
        result = []
        for single_means_of_transport in self.get_means_of_transport():
            result += self.get_lines(single_means_of_transport)
        return tuple(result)

    def get_line_details(self, identifier: str) -> LineDetails:
        return self._lines[identifier]
