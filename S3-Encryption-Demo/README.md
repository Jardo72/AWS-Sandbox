# S3 Encryption Demo

## Introduction

## Deployment

```
aws cloudformation create-stack --stack-name S3-Encryption-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --on-failure ROLLBACK
```
