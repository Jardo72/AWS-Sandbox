# S3 Replication Demo

## Introduction

## Deployment

```
aws cloudformation create-stack --stack-name S3-Replication-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --on-failure ROLLBACK
```
