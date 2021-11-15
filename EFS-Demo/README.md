# EFS Demo

## Introduction

## Deployment

```
aws cloudformation create-stack --stack-name EFS-Demo --template-body file://cloud-formation-template.yml --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
