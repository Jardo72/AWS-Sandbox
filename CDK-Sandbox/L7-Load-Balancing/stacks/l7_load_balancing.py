from aws_cdk import (
    aws_ec2 as ec2,
    aws_elasticloadbalancingv2 as elb,
    aws_iam as iam,
    Fn,
    Stack,
)
from constructs import Construct


user_data = """MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==BOUNDARY=="

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
echo "Running custom user data script"

--==BOUNDARY==--\
"""


class L7LoadBalancingStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        vpc = self._create_vpc()
        alb_security_group = self._create_alb_security_group(vpc)
        ec2_security_group = self._create_ec2_security_group(vpc)
        ec2_instance_profile = self._create_ec2_instance_profile()
        launch_template = self._create_launch_template(ec2_security_group, ec2_instance_profile)
        load_balancer = self._create_load_balancer(vpc)

    def _create_vpc(self) -> ec2.Vpc:
        return ec2.Vpc(self,
            id="VPC",
            vpc_name="L7-LB-Demo-VPC",
            cidr="10.0.0.0/16",
            enable_dns_hostnames=True,
            enable_dns_support=True,
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name="Public",
                    subnet_type=ec2.SubnetType.PUBLIC,
                    cidr_mask=24
                )
            ],
            max_azs=3
        )

    def _create_alb_security_group(self, vpc: ec2.Vpc) -> ec2.SecurityGroup:
        alb_security_group = ec2.SecurityGroup(self,
            id="ALBSecurityGroup",
            security_group_name="L7-LB-Demo-ALB-SG",
            vpc=vpc,
            description="Security group for the application load balancer",
            allow_all_outbound=False
        )
        alb_security_group.add_ingress_rule(
            peer=ec2.Peer.any_ipv4(),
            connection=ec2.Port.tcp(80),
            description="Allow HTTP traffic from anywhere"
        )
        alb_security_group.add_egress_rule(
            peer=ec2.Peer.ipv4("10.0.0.0/16"),
            connection=ec2.Port.tcp(80),
            description="Allow outbound traffic to the EC2 instances"
        )
        return alb_security_group

    def _create_ec2_security_group(self, vpc: ec2.Vpc) -> ec2.SecurityGroup:
        ec2_security_group = ec2.SecurityGroup(self,
            id="EC2SecurityGroup",
            security_group_name="L7-LB-Demo-ASG-SG",
            vpc=vpc,
            description="Security group for the EC2 instances",
            allow_all_outbound=True
        )
        ec2_security_group.add_ingress_rule(
            peer=ec2.Peer.any_ipv4(),
            connection=ec2.Port.tcp(80),
            description="Allow HTTP traffic from anywhere"
        )
        return ec2_security_group

    def _create_ec2_instance_profile(self) -> iam.CfnInstanceProfile:
        ec2_instance_role = iam.Role(self,
            id="EC2IAMRole",
            assumed_by=iam.ServicePrincipal(service="ec2.amazonaws.com"),
            role_name="L7-LB-Demo-EC2-IAM-Role",
            managed_policies=[
                # TODO: we also need access to the deployment artifactory S3 bucket
                iam.ManagedPolicy.from_aws_managed_policy_name(managed_policy_name="service-role/AmazonEC2RoleforSSM"),
            ]
        )
        ec2_instance_profile = iam.CfnInstanceProfile(self,
            id="EC2InstanceProfile",
            instance_profile_name="L7-LB-Demo-EC2-Instance-Profile",
            roles=[ec2_instance_role.role_name]
        )
        return ec2_instance_profile

    def _create_launch_template(self, security_group: ec2.SecurityGroup, instance_profile: iam.CfnInstanceProfile) -> ec2.CfnLaunchTemplate:
        launch_template = ec2.CfnLaunchTemplate(self,
            id="LaunchTemplate",
            launch_template_name="L7-LB-Demo-Launch-Template",
            launch_template_data=ec2.CfnLaunchTemplate.LaunchTemplateDataProperty(
                image_id="ami-0a1ee2fb28fe05df3",
                instance_type="t2.micro",
                # iam_instance_profile=instance_profile.attr_arn,
                security_group_ids=[
                    security_group.security_group_id
                ],
                user_data=Fn.base64(user_data)
            )
        )
        return launch_template

    def _create_load_balancer(self, vpc: ec2.Vpc) -> elb.ApplicationLoadBalancer:
        load_balancer = elb.ApplicationLoadBalancer(self,
            id="LoadBalancer",
            vpc=vpc,
            internet_facing=True
        )
        # listener = load_balancer.add_listener("HTTP-Listener", port=80)
        return load_balancer
