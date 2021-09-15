# TODO

## Introduction
- simple Python Flask application exposing few API endpoints
- single Python source file
- illustration of deployment to ECS (ECS service, Fargate launch type as well as EC2 launch type)

API endpoints
- `GET /version`
- `GET /hostname`
- `GET /start-time`
- `GET /environment-variables`
- `GET /consume-cpu`

## How to Start the Application

```
python application.py
```

## CI/CD Setup

```
aws cloudformation create-stack --stack-name CI-CD-Demo --template-body file://cloud-formation-template-ci-cd.yml --parameters file://stack-params-ci-cd.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

## Simple ECS Service Deployment Using Fargate Launch Type

```
aws cloudformation create-stack --stack-name ECS-Fargate-Demo --template-body file://cloud-formation-template-fargate.yml --parameters file://stack-params-fargate.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK

```

## Simple ECS Service Deployment Using EC2 Launch Type

```
```
