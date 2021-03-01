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
from time import perf_counter
from threading import Lock
from typing import Dict, List, Optional, Tuple

from graphlib.algorithms import find_shortest_path, ShortestPathSearchRequest
from graphlib.graph import AdjacencySetGraph, Edge, GraphType

from model import LineDetails, LineDirectionDetails, Model, Station


@dataclass(frozen=True)
class JourneyLeg:
    start: str
    destination: str
    means_of_transport: str
    line: str
    stop_count: int
    duration_minutes: int


@dataclass(frozen=True)
class JourneyPlan:
    start: str
    destination: str
    legs: Tuple[JourneyLeg, ...]

    @property
    def leg_count(self) -> int:
        return len(self.legs)

    @property
    def overall_stop_count(self) -> int:
        return sum(map(lambda i: i.stop_count, self.legs))

    @property
    def overall_duration_minutes(self) -> int:
        return sum(map(lambda i: i.duration_minutes, self.legs))


@dataclass(frozen=True)
class StatisticsSnapshot:
    request_count: int
    avg_request_duration_millis: int
    min_request_duration_millis: int
    max_request_duration_millis: int


class _JourneyPlanBuilder:

    def __init__(self) -> None:
        self._legs: List[JourneyLeg] = []
        self._current_leg: List[Edge] = []
        self._current_line: Optional[LineDetails] = None

    def _summarize_current_leg(self) -> JourneyLeg:
        start = self._current_leg[0].start
        destination = self._current_leg[-1].destination
        stop_count = len(self._current_leg)
        duration = sum(map(lambda edge: edge.weight, self._current_leg))
        return JourneyLeg(start, destination, self._current_line.means_of_transport, self._current_line.identifier, stop_count, duration)

    def add_edge(self, edge: Edge, line: LineDetails) -> None:
        if self._current_line is None:
            self._current_leg.append(edge)
            self._current_line = line
            return
        
        if self._current_line == line:
            self._current_leg.append(edge)
            return

        self._legs.append(self._summarize_current_leg())
        self._current_leg = [edge]
        self._current_line = line

    def build(self) -> JourneyPlan:
        self._legs.append(self._summarize_current_leg())
        start = self._legs[0].start
        destination = self._legs[-1].destination
        return JourneyPlan(start, destination, tuple(self._legs))


class _Statistics:

    def __init__(self):
        self._request_counter = 0
        self._overall_duration = 0
        self._max_duration = self._min_duration = -1
        self._lock = Lock()

    def request_handled(self, duration_millis: int) -> None:
        self._lock.acquire()
        try:
            self._request_counter += 1
            self._overall_duration += duration_millis
            if self._max_duration == -1 or self._max_duration < duration_millis:
                self._max_duration = duration_millis
            if self._min_duration == -1 or self._min_duration > duration_millis:
                self._min_duration = duration_millis
        finally:
            self._lock.release()

    def get_snapshot(self) -> StatisticsSnapshot:
        self._lock.acquire()
        try:
            if self._request_counter == 0:
                return StatisticsSnapshot(self._request_counter, 0, 0, 0)
            avg_duration = int(self._overall_duration / self._request_counter)
            return StatisticsSnapshot(self._request_counter, avg_duration, self._min_duration, self._max_duration)
        finally:
            self._lock.release()


class _EdgeToLineMapping:

    def __init__(self) -> None:
        self._entries: Dict[str, Dict[str, LineDetails]] = {}

    def add_edge(self, start: str, destination: str, line: LineDetails) -> None:
        if not start in self._entries:
            self._entries[start] = {}
        self._entries[start][destination] = line

    def get_line(self, start: str, destination: str) -> LineDetails:
        return self._entries[start][destination]


class _GraphBuilder:

    def __init__(self, model: Model) -> None:
        self._graph = AdjacencySetGraph(GraphType.DIRECTED)
        self._edge_to_line_mapping = _EdgeToLineMapping()
        self._model = model

    def _add_line_direction_to_graph(self, line_details: LineDetails, line_direction: LineDirectionDetails) -> None:
        previous_station = line_direction.itinerary[0]
        for current_station in line_direction.itinerary[1:]:
            distance = current_station.point_in_time - previous_station.point_in_time
            self._graph.add_edge(previous_station.name, current_station.name, distance)
            self._edge_to_line_mapping.add_edge(previous_station.name, current_station.name, line_details)
            previous_station = current_station

    def build(self) -> Tuple[AdjacencySetGraph, _EdgeToLineMapping]:
        for single_line in self._model.get_all_lines():
            line_details = self._model.get_line_details(single_line)
            self._add_line_direction_to_graph(line_details, line_details.direction_one)
            self._add_line_direction_to_graph(line_details, line_details.direction_two)
        return (self._graph, self._edge_to_line_mapping)


class Service:

    def __init__(self, model: Model) -> None:
        self._statistics = _Statistics()
        self._model = model
        self._graph, self._edge_to_line_mapping = _GraphBuilder(model).build()

    @property
    def model_version(self) -> str:
        return self._model.version

    def get_means_of_transport(self) -> Tuple[str, ...]:
        return self._model.get_means_of_transport()

    def get_all_lines(self)  -> Tuple[str, ...]:
        return self._model.get_all_lines()

    def get_lines(self, means_of_transport: str) -> Tuple[str, ...]:
        return self._model.get_lines(means_of_transport)

    def get_line_details(self, identifier: str) -> LineDetails:
        return self._model.get_line_details(identifier)

    def calculate_journey_plan(self, start: str, destination: str) -> JourneyPlan:
        start_time = perf_counter()
        request = ShortestPathSearchRequest(self._graph, start, destination)
        search_result = find_shortest_path(request)
        duration = perf_counter() - start_time
        self._statistics.request_handled(int(1000 * duration))

        plan_builder = _JourneyPlanBuilder()
        for single_edge in search_result.path:
            line = self._edge_to_line_mapping.get_line(single_edge.start, single_edge.destination)
            plan_builder.add_edge(single_edge, line)
        return plan_builder.build()

    def get_calculation_statistics(self) -> StatisticsSnapshot:
        return self._statistics.get_snapshot()
