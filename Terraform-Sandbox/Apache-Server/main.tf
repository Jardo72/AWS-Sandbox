provider "aws" {
    region = "eu-central-1"
}

resource "aws_vpc" "ApacheVPC" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags = {
        Name = "Apache-VPC"
    }
}

resource "aws_internet_gateway" "ApacheIGV" {
    vpc_id = aws_vpc.ApacheVPC.id
}

resource "aws_subnet" "ApachePublicSubnet" {
    vpc_id = aws_vpc.ApacheVPC.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "Apache-Public-Subnet"
    }
}

resource "aws_route_table" "PublicRouteTable" {
    vpc_id = aws_vpc.ApacheVPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ApacheIGV.id
    }
    tags = {
        Name = "Apache-Public-Route-Table"
    }
}

resource "aws_route_table_association" "PublicRouteTableAssociation" {
    subnet_id = aws_subnet.ApachePublicSubnet.id
    route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_security_group" "WebServerSG" {
    name = "Web-Server-SG"
    description = "Allow inbound HTTP(S) traffic from any origin"
    vpc_id = aws_vpc.ApacheVPC.id

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

    tags = {
        Name = "Web-Server-SG"
    }
}

resource "aws_eip" "WebServerElasticIP" {
    instance = aws_instance.WebServer.id
    vpc = true
}

resource "aws_instance" "WebServer" {
    ami = "ami-09439f09c55136ecf"
    instance_type = "t2.nano"
    subnet_id = aws_subnet.ApachePublicSubnet.id
    vpc_security_group_ids = [aws_security_group.WebServerSG.id]
    user_data = file("user-data.sh")
    tags = {
        Name = "WebServer"
    }
    lifecycle {
        create_before_destroy = true
    }
}
