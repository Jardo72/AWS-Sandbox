# CloudFormation Sandbox

# Introduction
Collection of CloudFormation templates illustrating various CloudFormation concepts.


## Cross-Stack Reference Demo
Creates two stacks - one with IAM role, the other with a Lambda function that uses the IAM role as execution role for the Lambda function. The ARN of the IAM role is exported from the first stack and imported into the second stack.

Source code:
- [lambda-execution-role-template.yml](./lambda-execution-role-template.yml)
- [lambda-function-template.yml](./lambda-function-template.yml)

Deployment via AWS CLI:
```
aws cloudformation create-stack --stack-name CFN-Sandbox-Lambda-Execution-Role --template-body file://lambda-execution-role-template.yml --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK

aws cloudformation create-stack --stack-name CFN-Sandbox-Lambda-Function --template-body file://lambda-function-template.yml --on-failure ROLLBACK
```


## Nested Stacks Demo
Creates a stack with two nested stacks. The parent stack creates an IAM role whose ARN is passed as parameter to the nested stacks which use it as execution role for a Lambda function.

Source code:
- [nested-stacks-parent-template.yml](./nested-stacks-parent-template.yml)
- [nested-stacks-parent-params.json](./nested-stacks-parent-params.json)
- [nested-stack-template.yml](./nested-stack-template.yml)

Deployment via AWS CLI (the nested stack template must be stored in an S3 bucket - the URL is specified as parameter):
```
aws cloudformation create-stack --stack-name CFN-Sandbox-Nested-Stacks --template-body file://nested-stacks-parent-template.yml --parameters file://nested-stacks-parent-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```


## Conditions Demo
Illustrates application of conditions in CloudFormation templates. The template involves three Lambda functions whose creation is driven by conditions that evaluate template parameters. 

Source code:
- [conditions-template.yml](./conditions-template.yml)
- [conditions-params.json](./conditions-params.json)

Deployment via AWS CLI:
```
aws cloudformation create-stack --stack-name CFN-Sandbox-Conditions --template-body file://conditions-template.yml --parameters file://conditions-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```


## Intrinsic Functions Demo
Creates a stack with a dummy IAM policy and several output values produced by various intrinsic functions. The IAM policy is not used - it is there just to keep CloudFormation happy as there must be at least one reource in every template.

Source code:
- [intrinsic-functions-demo-template.yml](./intrinsic-functions-demo-template.yml)

Deployment via AWS CLI:
```
aws cloudformation create-stack --stack-name CFN-Sandbox-Intrinsic-Functions --template-body file://intrinsic-functions-demo-template.yml --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```


## CFN Signal Demo
Launches an EC2 instance which sends a cfn-signal during the bootstrapping. The CloudFormation template involves a creation policy which waits for the signal from the EC2 instance.

Source code:
- [creation-policy-cfn-signal-template.yml](./creation-policy-cfn-signal-template.yml)

Deployment via AWS CLI:
```
aws cloudformation create-stack --stack-name CFN-Creation-Policy-Signal --template-body file://creation-policy-cfn-signal-template.yml --on-failure ROLLBACK
```


## Change-Set Demo
Demonstration of CloudFormation change-sets.

Source code:
- [change-set-template-v1.yml](./change-set-template-v1.yml)
- [change-set-template-v2.yml](./change-set-template-v2.yml)
- [change-set-template-v3.yml](./change-set-template-v3.yml)

Deployment of template version 1 via AWS CLI:
```
aws cloudformation create-stack --stack-name CFN-Change-Set --template-body file://change-set-template-v1.yml --on-failure ROLLBACK
```

It is better to update the stack (apply version 2 and 3 of the template) via the AWS Management Console where change-sets are presented visually.


## Helper Scripts Demo
Demonstration of CloudFormation helper scripts (cfn-init, cfn-hup).

Source code:
- [helper-scripts-template.yml](./helper-scripts-template.yml)

Deployment of template version 1 via AWS CLI:
```
aws cloudformation create-stack --stack-name CFN-Helper-Scripts --template-body file://helper-scripts-template.yml --on-failure ROLLBACK
```

In order to demonstrate the cfn-hup functionality, update the stack using the same template via the AWS Management Console, but use a different value for the message parameter.
