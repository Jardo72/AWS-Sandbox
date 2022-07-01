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

output "aws_account_id" {
  value = data.aws_caller_identity.current_account.account_id
}

output "latest_amazon_linux_ami" {
  value = data.aws_ami.latest_amazon_linux_ami.id
}

output "web_server_elastic_ip" {
  value = aws_eip.web_server_elastic_ip.public_ip
}

output "web_server_elastic_dns_name" {
  value = aws_eip.web_server_elastic_ip.public_dns
}

output "web_server_instance_id" {
  value = aws_instance.web_server.id
}

output "generated_random_password" {
  value = nonsensitive(random_password.dummy_password.result)
}