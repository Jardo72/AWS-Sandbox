# IAM Policy Sandbox

## Introduction
Demonstration of [IAM policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html). 

| S3 Bucket           | Bucket Policy   | Permissions Boundary   | Identity-Based Policy   | Final Access Decision |
| ------------------- |:---------------:|:----------------------:|:-----------------------:|:---------------------:|
| AllowedBucket       | Allow           | No Statement           | No Statement            | <span style="color:green">Allow<span> |
| DeniedBucket        | Deny            | Allow                  | Allow                   | <span style="color:red">Deny<span> |
| NoPolicyBucketOne   | N/A             | Allow                  | No Statement            | <span style="color:red">Deny<span> |
| NoPolicyBucketTwo   | N/A             | No Statement           | Allow                   | <span style="color:red">Deny<span> |
| NoPolicyBucketThree | N/A             | Allow                  | Allow                   | <span style="color:green">Allow<span> |

## Deployment

```
aws cloudformation create-stack --stack-name IAM-Policy-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
