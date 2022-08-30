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

from argparse import ArgumentParser, RawTextHelpFormatter
from boto3 import resource
from botocore.exceptions import ClientError
from dataclasses import dataclass
from json import dumps
from typing import Any, Dict, List


@dataclass(frozen=True)
class CredentialsDeactivationResult:
    success: bool
    detail: str


@dataclass(frozen=True)
class UserDeactivationResult:
    user_name: str
    login_profile_removal: CredentialsDeactivationResult
    access_key_deactivation: CredentialsDeactivationResult

    @property
    def success(self) -> bool:
        return self.login_profile_removal.success and self.access_key_deactivation.success


class IAMUserDeactivator:

    def __init__(self) -> None:
        self._iam = resource("iam")

    def deactivate_user(self, name: str) -> UserDeactivationResult:
        try:
            print()
            print(80 * "=")
            print(f"Deactivating the user {name}")
            user = self._iam.User(name)
            access_key_deactivation = self._deactivate_access_keys(user)
            login_profile_removal = self._remove_login_profile(user)
            print(f"User {name} processed")
            print()
            return UserDeactivationResult(
                user_name=name,
                login_profile_removal=login_profile_removal,
                access_key_deactivation=access_key_deactivation
            )
        except ClientError as error:
            message = str(error)
            return UserDeactivationResult(
                user_name=name,
                login_profile_removal=CredentialsDeactivationResult(success=False, detail=message),
                access_key_deactivation=CredentialsDeactivationResult(success=False, detail=message)
            )

    def _deactivate_access_keys(self, user) -> CredentialsDeactivationResult:
        try:
            inactive_key_count = deactivated_key_count = 0
            print(f"Deactivating access keys for the user {user.name}")
            for single_access_key in user.access_keys.all():
                if single_access_key.status == "Inactive":
                    print(f"Access key {single_access_key.access_key_id} already inactive, nothing to do")
                    inactive_key_count += 1
                    continue
                print(f"Deactivating the access key {single_access_key.access_key_id}")
                single_access_key.deactivate()
                deactivated_key_count += 1
            message = f"{inactive_key_count} key(s) already inactive, {deactivated_key_count} key(s) deactivated"
            return CredentialsDeactivationResult(success=True, detail=message)
        except ClientError as error:
            message = str(error)
            print(f"ERROR!!! Failed to deactivate access key for user {user.name}: {message}")
            return CredentialsDeactivationResult(success=False, detail=message)

    def _remove_login_profile(self, user) -> CredentialsDeactivationResult:
        print(f"Deleting login profile for the user {user.name}")
        login_profile = self._iam.LoginProfile(user.name)
        try:
            print(f"Deleting login profile for the user {user.name}")
            login_profile.delete()
            return CredentialsDeactivationResult(success=True, detail="Login profile deleted")
        except ClientError as error:
            message = str(error)
            if error.response["Error"]["Code"] == "NoSuchEntity":
                print(f"Login profile for the user {user.name} not found - nothing to do")
                return CredentialsDeactivationResult(success=True, detail="Login profile not found - nothing to be deleted")
            print(f"ERROR!!! Failed to remove login profile for user {user.name}: {message}")
            return CredentialsDeactivationResult(success=False, detail=message)


def create_command_line_arguments_parser() -> ArgumentParser:
    parser = ArgumentParser(description="Deactivation of IAM Users", formatter_class=RawTextHelpFormatter)

    # positional mandatory arguments
    parser.add_argument("inactive_users_report_file",
        help = "the name of the input file containing the names of inactive users (TXT format, single name per line)")
    parser.add_argument("deactivated_users_report_file",
        help = "the name of the output file the generated report with deactivated IAM users is to be written to")

    return parser


def parse_command_line_arguments():
    parser = create_command_line_arguments_parser()
    params = parser.parse_args()
    return params


def load_user_names(filename: str) -> List[str]:
    with open(filename, "r") as input_file:
        return input_file.readlines()


def deactivate_users(users: List[str]) -> List[UserDeactivationResult]:
    result_list = []
    deactivator = IAMUserDeactivator()
    for single_user in users:
        result = deactivator.deactivate_user(single_user)
        result_list.append(result)
    return result_list


def convert_to_dict(user_deactivation_result: UserDeactivationResult) -> Dict[str, Any]:
    return {
        "success": user_deactivation_result.success,
        "login-profile-removal": {
            "success": user_deactivation_result.login_profile_removal.success,
            "detail": user_deactivation_result.login_profile_removal.detail
        },
        "access-key-deactivation": {
            "success": user_deactivation_result.access_key_deactivation.success,
            "detail": user_deactivation_result.access_key_deactivation.detail
        }
    }


def write_results_report(filename: str, result_list: List[UserDeactivationResult]) -> None:
    data = {result.user_name: convert_to_dict(result) for result in result_list}
    with open(filename, "w") as output_file:
        output_file.write(dumps(data, indent=4, sort_keys=True))


def print_summary(inactive_users: List[str], result_list: List[UserDeactivationResult]) -> None:
    success_count = 0
    error_count = 0
    for result in result_list:
        if result.success:
            success_count += 1
        else:
            error_count += 1
    print()
    print(80 * "=")
    print("Summary")
    print(f"Number of users from input resport:     {len(inactive_users)}")
    print(f"Number of successfully processed users: {success_count}")
    print(f"Number of failed users:                 {error_count}")
    print()


def main() -> None:
    command_line_arguments = parse_command_line_arguments()
    inactive_users = load_user_names(command_line_arguments.inactive_users_report_file)
    result_list = deactivate_users(inactive_users)
    write_results_report(command_line_arguments.deactivated_users_report_file, result_list)
    print_summary(inactive_users, result_list)


if __name__ == "__main__":
    main()
