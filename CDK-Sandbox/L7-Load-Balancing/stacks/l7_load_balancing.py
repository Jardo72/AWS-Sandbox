from aws_cdk import (
    aws_ec2 as ec2,
    Stack,
)
from constructs import Construct

class L7LoadBalancingStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        vpc = self._create_vpc()
        alb_security_group = self._create_alb_security_group(vpc)
        ec2_security_group = self._create_ec2_security_group(vpc)

    def _create_vpc(self) -> ec2.Vpc:
        return ec2.Vpc(self, "L7-LB-Demo-VPC",
            vpc_name="L7-LB-Demo-VPC",
            cidr="10.0.0.0/16",
            enable_dns_hostnames=True,
            enable_dns_support=True,
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name="Public",
                    subnet_type=ec2.SubnetType.PUBLIC,
                    cidr_mask=24
                ),
                # TODO:
                # it seems it will automatically create such a subnet in each AZ, so single entry
                # should be enough
                # ec2.SubnetConfiguration(
                #     name="Public-2",
                #     subnet_type=ec2.SubnetType.PUBLIC,
                #     cidr_mask=24
                # ),
                # ec2.SubnetConfiguration(
                #     name="Public-3",
                #     subnet_type=ec2.SubnetType.PUBLIC,
                #     cidr_mask=24
                # ),
            ],
            max_azs=3
        )

    def _create_alb_security_group(self, vpc: ec2.Vpc) -> ec2.SecurityGroup:
        alb_security_group = ec2.SecurityGroup(self, "ALB-Security-Group"
            security_group_name="L7-LB-Demo-ALB-SG",
            vpc=vpc,
            description="Security group for the application load balancer",
            allow_all_outbound=False
        )
        return alb_security_group

    def _create_ec2_security_group(self, vpc: ec2.Vpc) -> ec2.SecurityGroup:
        ec2_security_group = ec2.SecurityGroup(self, "ALB-Security-Group"
            security_group_name="L7-LB-Demo-ASG-SG",
            vpc=vpc,
            description="Security group for the EC2 instances",
            allow_all_outbound=True
        )
        return ec2_security_group

