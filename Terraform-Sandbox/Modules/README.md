# Terraform Module Demo

## Introduction
Demonstration of Terraform module which creates a VPC with a pair of subnets (public subnet and private subnet) for each of the specified AZs. In each of the public subnets, NAT gateway is created. The route tables for the private subnets involve a default route to the NAT gateway residing in the same AZ as the private subnet. The VPC has also an Internet Gateway attached, and the route table associated with the public subnets involves a default route to the Internet Gateway.

## Terraform Variables

```hcl
vpc_cidr_block = "10.0.0.0/16"

availability_zones = {
  "AZ-1" = {
    az_name                   = "eu-central-1a"
    private_subnet_cidr_block = "10.0.0.0/24"
    public_subnet_cidr_block  = "10.0.10.0/24"
  },
  "AZ-2" = {
    az_name                   = "eu-central-1b"
    private_subnet_cidr_block = "10.0.1.0/24"
    public_subnet_cidr_block  = "10.0.11.0/24"
  },
  "AZ-3" = {
    az_name                   = "eu-central-1c"
    private_subnet_cidr_block = "10.0.2.0/24"
    public_subnet_cidr_block  = "10.0.12.0/24"
  }
}

resource_name_prefix = "Module-Demo"

tags = {
  ProvisionedBy = "Terraform",
  Stack         = "Terraform-Module-Demo"
}
```
