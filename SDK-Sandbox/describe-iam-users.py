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


def dump_single_user(iam_user):
    print()
    print(60 * "=")
    print(f"User ID:            {iam_user['UserId']}")
    print(f"User name:          {iam_user['UserName']}")
    print(f"ARN:                {iam_user['Arn']}")
    print(f"Create date:        {iam_user['CreateDate']}")
    if "PasswordLastUsed" in iam_user:
        print(f"Password last used: {iam_user['PasswordLastUsed']}")
    if "Tags" in iam_user:
        dump_tags(iam_user["Tags"])


def main():
    iam_client = client("iam")
    response = iam_client.list_users(MaxItems=100)
    for single_user in response["Users"]:
        iam_user = iam_client.get_user(UserName=single_user['UserName'])
        dump_single_user(iam_user["User"])


if __name__ == "__main__":
    main()
