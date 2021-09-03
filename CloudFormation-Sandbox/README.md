#

# Introduction

## Cross-Stack Reference Demo

```
aws cloudformation create-stack --stack-name CFN-Sandbox-Lambda-Execution-Role --template-body file://lambda-execution-role-template.yml --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

```
aws cloudformation create-stack --stack-name CFN-Sandbox-Lambda-Function --template-body file://lambda-function-template.yml --on-failure ROLLBACK
```

## 
