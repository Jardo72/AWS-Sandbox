# IAM Policy Sandbox

## Introduction

|  S3 Bucket     |  Bucket Policy  |  Permissions Boundary  |  Identity-Based Policy  |  Access Decision   |
| -------------- |:---------------:|:----------------------:|:-----------------------:|:------------------:|
| AllowedBucket  | Allow           | No Statement           | No Statement            | Allow              |
| DeniedBucket   | Deny            | Allow                  | Allow                   | Deny               |
| TODO           | No Statement    | Allow                  | No Statement            | Deny               |
| TODO           | No Statement    | No Statement           | Allow                   | Deny               |
| TODO           | No Statement    | Allow                  | Allow                   | Allow              |

## Deployment

```
aws cloudformation create-stack --stack-name IAM-Policy-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
