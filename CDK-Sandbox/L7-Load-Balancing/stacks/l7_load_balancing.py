from aws_cdk import (
    aws_ec2 as ec2,
    Stack,
)
from constructs import Construct

class L7LoadBalancingStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        ec2.Vpc(self, "L7-LB-Demo-VPC",
            vpc_name="L7-LB-Demo-VPC",
            cidr="10.0.0.0/16",
            enable_dns_hostnames=True,
            enable_dns_support=True,
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name="Public-1",
                    subnet_type=ec2.SubnetType.PUBLIC,
                    cidr_mask=24
                ),
                ec2.SubnetConfiguration(
                    name="Public-2",
                    subnet_type=ec2.SubnetType.PUBLIC,
                    cidr_mask=24
                ),
                ec2.SubnetConfiguration(
                    name="Public-3",
                    subnet_type=ec2.SubnetType.PUBLIC,
                    cidr_mask=24
                ),
            ],
        )

