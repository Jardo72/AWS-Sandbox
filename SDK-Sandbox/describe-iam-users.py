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

from boto3 import client, resource
from botocore.exceptions import ClientError


def dump_tags(tags):
    if tags is None:
        return
    print("Tags:")
    for single_tag in tags:
        print(f"  {single_tag['Key']} = {single_tag['Value']}")


def dump_login_profile(iam_resource, iam_user):
    login_profile = iam_resource.LoginProfile(iam_user.name)
    try:
        create_date = login_profile.create_date
        print("Login Profile:")
        print(f"  - creation date: {create_date}")
    except ClientError:
        pass


def dump_access_keys(iam_resource, iam_user):
    try:
        print("Access Keys:")
        for single_access_key in iam_user.access_keys.all():
            print(f"  - access key ID: {single_access_key.access_key_id}")
            print(f"    create date:   {single_access_key.create_date}")
            print(f"    status:        {single_access_key.status}")
    except ClientError:
        pass


def dump_single_user(iam_resource, iam_user):
    print()
    print(60 * "=")
    print(f"User ID:     {iam_user.user_id}")
    print(f"User name:   {iam_user.user_name}")
    print(f"ARN:         {iam_user.arn}")
    print(f"Create date: {iam_user.create_date}")
    dump_login_profile(iam_resource, iam_user)
    dump_access_keys(iam_resource, iam_user)
    dump_tags(iam_user.tags)


def main():
    iam_resource = resource("iam")
    iam_client = client("iam")
    response = iam_client.list_users(MaxItems=100)
    for single_user in response["Users"]:
        user_name = single_user['UserName']
        user = iam_resource.User(user_name)
        dump_single_user(iam_resource, user)


if __name__ == "__main__":
    main()
