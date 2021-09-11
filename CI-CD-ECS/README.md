# TODO

## Introduction
- simple Python Flask application exposing few API endpoints
- single Python source file

API endpoints
- `GET /version`
- `GET /hostname`
- `GET /start-time`
- `GET /environment-variables`

## How to Start the Application

```
python application.py
```


## ECS Deployment - Fargate Launch Type

```
aws cloudformation create-stack --stack-name ECS-Fargate-Demo --template-body file://cloud-formation-template-fargate.yml --parameters file://stack-params-fargate.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK

```

## ECS Deployment - EC2 Type

```
```
