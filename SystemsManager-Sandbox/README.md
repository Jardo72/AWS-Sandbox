# Systems Manager Sandbox

## Introduction
CloudFormation that creates four EC2 instances that can be used for manual experiments with Systems Manager, for instance configuration of patching groups, configuration of maintenance windows etc. The instances are tagged, so the configurations can be based on tags.

| Name (tag)             | Patch Group (tag)  |
| ---------------------- |:------------------:|
| SSM-Sandbox-Instance-1 | Blue               |
| SSM-Sandbox-Instance-2 | Green              |
| SSM-Sandbox-Instance-3 | Blue               |
| SSM-Sandbox-Instance-4 | Green              |

## Deployment
The deployment is very simple, there is no need to specify any parameters.
```
aws cloudformation create-stack --stack-name SSM-Sandbox --template-body file://cloud-formation-template.yml --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
