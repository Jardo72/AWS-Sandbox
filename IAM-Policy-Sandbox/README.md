# IAM Policy Sandbox

## Introduction
Demonstration of [IAM policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html). 

| S3 Bucket           | Bucket Policy   | Permissions Boundary   | Identity-Based Policy   | Final Access Decision |
| ------------------- |:---------------:|:----------------------:|:-----------------------:|:---------------------:|
| AllowedBucket       | Allow           | No Statement           | No Statement            | Allow                 |
| DeniedBucket        | Deny            | Allow                  | Allow                   | Deny                  |
| NoPolicyBucketOne   | N/A             | Allow                  | No Statement            | Deny                  |
| NoPolicyBucketTwo   | N/A             | No Statement           | Allow                   | Deny                  |
| NoPolicyBucketThree | N/A             | Allow                  | Allow                   | Allow                 |

## Deployment

```
aws cloudformation create-stack --stack-name IAM-Policy-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
