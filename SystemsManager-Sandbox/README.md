# Systems Manager Sandbox

## Introduction
CloudFormation that creates six EC2 instances that can be used for manual experiments with Systems Manager, for instance configuration of patching groups, configuration of maintenance windows etc. The instances are tagged, so the configurations can be based on tags.

| Name (tag)             | Patch Group (tag)  | Environment (tag) |
| ---------------------- | ------------------ | ----------------- |
| SSM-Sandbox-Instance-1 | Blue               | Development       |
| SSM-Sandbox-Instance-2 | Green              | Production        |
| SSM-Sandbox-Instance-3 | Blue               | Production        |
| SSM-Sandbox-Instance-4 | Green              | Production        |
| SSM-Sandbox-Instance-5 | Blue               | Development       |
| SSM-Sandbox-Instance-6 | Green              | Production        |

Besides the instances, two resource groups are also created. Both resource groups are used to group resources of the type EC2 instance. The first group involves EC2 instance tagged with the Environment tag having the value Development, the other group involves EC2 instance tagged with the Environment tag having the value Production.

## Deployment
The deployment is very simple, there is no need to specify any parameters.
```
aws cloudformation create-stack --stack-name SSM-Sandbox --template-body file://cloud-formation-template.yml --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
