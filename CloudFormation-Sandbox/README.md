# CloudFormation Sandbox

# Introduction
Collection of CloudFormation templates illustrating various CloudFormation concepts.

## Cross-Stack Reference Demo

Source code:
- [lambda-execution-role-template.yml](./lambda-execution-role-template.yml)
- [lambda-function-template.yml](./lambda-function-template.yml)

Deployment via AWS CLI:
```
aws cloudformation create-stack --stack-name CFN-Sandbox-Lambda-Execution-Role --template-body file://lambda-execution-role-template.yml --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK

aws cloudformation create-stack --stack-name CFN-Sandbox-Lambda-Function --template-body file://lambda-function-template.yml --on-failure ROLLBACK
```

## Nested Stacks Demo

Source code:
- [nested-stacks-parent-template.yml](./nested-stacks-parent-template.yml)
- [nested-stack-template.yml](./nested-stack-template.yml)

Deployment via AWS CLI (the nested stack template must be stored in an S3 bucket - the URL is specified as parameter):
```
aws cloudformation create-stack --stack-name CFN-Sandbox-Nested-Stacks --template-body file://nested-stacks-parent-template.yml --parameters file://nested-stacks-parent-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
