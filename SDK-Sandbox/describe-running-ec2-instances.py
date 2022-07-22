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

from boto3 import client


def dump_tags(tags):
    print("Tags:")
    for single_tag in tags:
        print(f"  {single_tag['Key']} = {single_tag['Value']}")


def dump_sinlge_instance(instance_details):
    print()
    print(60 * "=")
    print(F"Instance ID:   {instance_details['InstanceId']}")
    print(F"Image ID:      {instance_details['ImageId']}")
    print(F"Instance type: {instance_details['InstanceType']}")
    print(F"State:         {instance_details['State']['Name']}")
    if "Platform" in instance_details:
        print(F"Platform:      {instance_details['Platform']}")
    if "Architecture" in instance_details:
        print(F"Architecture:  {instance_details['Architecture']}")
    dump_tags(instance_details["Tags"])


def main():
    ec2_client = client("ec2")
    response = ec2_client.describe_instances(
        Filters=[
            {
                "Name": "instance-state-name",
                "Values": [
                    "running"
                ]
            }
        ]
    )
    if len(response["Reservations"]) == 0:
        print("No running instance - nothing to be displayed")
        return

    for single_reservation in response["Reservations"]:
        for single_instance in single_reservation["Instances"]:
            dump_sinlge_instance(single_instance)


if __name__ == "__main__":
    main()
