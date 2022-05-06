# Systems Manager Sandbox

## Introduction
CloudFormation template that creates six EC2 instances that can be used for manual experiments with Systems Manager, for instance configuration of patching groups, configuration of maintenance windows etc. The instances are tagged (see the table below). Besides the instances, two resource groups are also created. Both resource groups are used to group resources of the type EC2 instance. The first group involves EC2 instance tagged with the Environment tag having the value Development, the other group involves EC2 instance tagged with the Environment tag having the value Production. Because, of the tagging, Systems Manager configurations and the activities performed be based on tags and resource groups.

| Name (tag)             | Patch Group (tag)  | Environment (tag) | OS             |
| ---------------------- | ------------------ | ----------------- | -------------- |
| SSM-Sandbox-Instance-1 | Blue               | Development       | Amazon Linux 2 |
| SSM-Sandbox-Instance-2 | Green              | Production        | Amazon Linux 2 |
| SSM-Sandbox-Instance-3 | Blue               | Production        | Amazon Linux 2 |
| SSM-Sandbox-Instance-4 | Green              | Production        | Amazon Linux 2 |
| SSM-Sandbox-Instance-5 | Blue               | Development       | Ubuntu         |
| SSM-Sandbox-Instance-6 | Green              | Production        | Ubuntu         |

Besides the instances, two resource groups are also created. Both resource groups are used to group resources of the type EC2 instance. The first group involves EC2 instance tagged with the Environment tag having the value Development, the other group involves EC2 instance tagged with the Environment tag having the value Production.

An IAM instance profile based on an IAM role with the AWS-managed policy AmazonEC2RoleforSSM is used for The EC2 instances, so they are ready to be used with the Systems Manager. The SSM agent is also installed (preinstalled on the AMI used).

## Deployment
The deployment is very simple, there is no need to specify any parameters.
```
aws cloudformation create-stack --stack-name SSM-Sandbox --template-body file://cloud-formation-template.yml --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
