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

vpc_cidr_block = "10.0.0.0/16"

availability_zones = {
  "AZ-1" = {
    az_name           = "eu-central-1a"
    subnet_cidr_block = "10.0.0.0/24"
  },
  "AZ-2" = {
    az_name           = "eu-central-1b"
    subnet_cidr_block = "10.0.1.0/24"
  },
  "AZ-3" = {
    az_name           = "eu-central-1c"
    subnet_cidr_block = "10.0.2.0/24"
  }
}

application_installation = {
  deployment_artifactory_bucket_name_export     = "CommonDeploymentArtifactoryBucketName"
  deployment_artifactory_access_role_arn_export = "CommonDeploymentArtifactoryReadAccessPolicyArn"
  deployment_artifactory_prefix                 = "L7-LB-DEMO"
  application_jar_file                          = "aws-sandbox-application-load-balancing-server-1.0.jar"
}

ec2_settings = {
  instance_type = "t2.nano"
  port          = 80
}

alb_access_log_settings = {
  bucket_name_export = "CommonELBAccessLogBucketName"
  prefix             = "L7-LB-Demo-Terraform"
  enabled            = true
}

autoscaling_group_settings = {
  min_size                         = 3
  max_size                         = 6
  desired_capacity                 = 3
  target_cpu_utilization_threshold = 50
}

route53_alias_settings = {
  enabled                = true
  alias_hosted_zone_name = "jardo72.de."
  alias_fqdn             = "alb-demo.jardo72.de"
}

resource_name_prefix = "L7-LB-Demo"

tags = {
  Stack         = "L7-Load-Balancing-Demo",
  ProvisionedBy = "Terraform"
}
