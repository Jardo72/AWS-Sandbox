#
# Copyright 2022 Jaroslav Chmurny
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

resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = var.dashboard_name
  dashboard_body = templatefile("${path.module}/dashboard-widgets.tftpl", {
    aws_region                                         = var.aws_region,
    load_balancer_arn                                  = var.load_balancer_arn,
    load_balancer_id                                   = replace(var.load_balancer_arn, "/.+:\\d{12}:loadbalancer//", "")
    target_group_arn                                   = var.target_group_arn,
    target_group_id                                    = replace(var.target_group_arn, "/.+:\\d{12}:/", "")
    autoscaling_group_name                             = var.autoscaling_group_name
    autoscaling_group_target_cpu_utilization_threshold = var.autoscaling_group_target_cpu_utilization_threshold
  })
}
