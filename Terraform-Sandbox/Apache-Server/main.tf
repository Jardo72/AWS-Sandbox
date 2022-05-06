locals {
    aws_region = "eu-central-1"
    ssm_parameter_name = "/terraform-sandbox/apache-server/dummy-password"
    common_tags = {
        Name = "Apache-Demo",
        ProvisionedBy = "Terraform"
    }
}

provider "aws" {
    region = local.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "CurrentVersionAMIID" {
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "random_password" "DummyPassword" {
    length = 12
    special = true
}

resource "aws_ssm_parameter" "DummyPassword" {
    description = "Dummy password for no real use"
    type = "SecureString"
    name = local.ssm_parameter_name
    value = random_password.DummyPassword.result
    tags = local.common_tags
}

resource "aws_vpc" "VPC" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags = local.common_tags
}

resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.VPC.id
    tags = local.common_tags
}

resource "aws_subnet" "PublicSubnet" {
    vpc_id = aws_vpc.VPC.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
    tags = local.common_tags
}

resource "aws_route_table" "PublicRouteTable" {
    vpc_id = aws_vpc.VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }
    tags = local.common_tags
}

resource "aws_route_table_association" "PublicRouteTableAssociation" {
    subnet_id = aws_subnet.PublicSubnet.id
    route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_security_group" "WebServerSG" {
    name = "Apache-Demo"
    description = "Allow inbound HTTP(S) traffic from any origin"
    vpc_id = aws_vpc.VPC.id

    dynamic "ingress" {
        for_each = ["80", "443"]
        content {
            protocol = "tcp"
            from_port = ingress.value
            to_port = ingress.value
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            description = "Allow inbound HTTP(S)"
        }
    }

    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = local.common_tags
}

resource "aws_eip" "WebServerElasticIP" {
    instance = aws_instance.WebServer.id
    vpc = true
    tags = local.common_tags
}

resource "aws_iam_role" "SSMParameterReaderRole" {
    name = "SSMParameterReaderRole"
    assume_role_policy = jsonencode({
        Version: "2012-10-17",
        Statement: [
            {
                Sid: "AllowEC2Assume",
                Action: "sts:AssumeRole",
                Principal: {
                    Service: "ec2.amazonaws.com"
                },
                Effect: "Allow"
            }
        ]
    })

    inline_policy {
        name = "SSMParameterValueReadAccess"
        policy = jsonencode({
            Version: "2012-10-17",
            Statement: [
                {
                    Sid: "AllowGetParameter",
                    Action: ["ssm:GetParameter"]
                    Effect: "Allow"
                    Resource: format("arn:aws:ssm:%s:%s:parameter%s", local.aws_region, data.aws_caller_identity.current.account_id, local.ssm_parameter_name)
                }
            ]
        })
    }

    tags = local.common_tags
}

resource "aws_iam_instance_profile" "SSMParameterReaderProfile" {
    name = "SSMParameterReaderProfile"
    role = aws_iam_role.SSMParameterReaderRole.name
    tags = local.common_tags
}

resource "aws_instance" "WebServer" {
    ami = data.aws_ssm_parameter.CurrentVersionAMIID.value
    instance_type = "t2.nano"
    subnet_id = aws_subnet.PublicSubnet.id
    vpc_security_group_ids = [aws_security_group.WebServerSG.id]
    iam_instance_profile = aws_iam_instance_profile.SSMParameterReaderProfile.name
    user_data = templatefile("user-data.tpl", {
        aws_region = local.aws_region
        ssm_parameter_name = local.ssm_parameter_name
    })
    tags = local.common_tags
    lifecycle {
        create_before_destroy = true
    }
    depends_on = [aws_ssm_parameter.DummyPassword]
}

output "AWSAccountID" {
    value = data.aws_caller_identity.current.account_id
}

output "CurrentVersionAMIID" {
    value = nonsensitive(data.aws_ssm_parameter.CurrentVersionAMIID.value)
}

output "WebServerElasticIP" {
    value = aws_eip.WebServerElasticIP.public_ip
}

output "WebServerElasticDNSName" {
    value = aws_eip.WebServerElasticIP.public_dns
}
