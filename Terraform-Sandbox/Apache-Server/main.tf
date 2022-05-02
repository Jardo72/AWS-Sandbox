provider "aws" {
    region = "eu-central-1"
}

resource "aws_vpc" "ApacheVPC" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
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
        cidr_block = 0.0.0.0/0
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

# resource "aws_instance" "WebServer" {
#
# }
