# IAM Policy Sandbox

## Introduction
Demonstration of [IAM policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html). This demo involves an IAM user with permissions boundary and an (inline) identity-based policy, plus several S3 buckets (two of them with bucket policies). The policies control access to the `s3:ListBucket` operation, which is also the underlying operation of the `aws s3 ls` AWS CLI command. The following table summarizes the setup.

| S3 Bucket           | Bucket Policy   | Permissions Boundary   | Identity-Based Policy   | Access   |
| ------------------- |:---------------:|:----------------------:|:-----------------------:|:--------:|
| AllowedBucket       | Allow           | No Statement           | No Statement            | Allowed  |
| DeniedBucket        | Deny            | Allow                  | Allow                   | Denied   |
| NoPolicyBucketOne   | N/A             | Allow                  | No Statement            | Denied   |
| NoPolicyBucketTwo   | N/A             | No Statement           | Allow                   | Denied   |
| NoPolicyBucketThree | N/A             | Allow                  | Allow                   | Allowed  |

In order to play around with the `aws s3 ls` AWS CLI command as the above mentioned IAM user, it is necessary to create an access key for the IAM user and incorporate it to the `~/.aws/credentials` file. Before experimenting with the `aws s3 ls` AWS CLI command, it also makes sense to upload some files to the buckets. The files in the [test-files](./test-files) directory can be used for this purpose.

## Deployment
The following AWS CLI command illustrates how to use the CloudFormation template to create the stack described in the previous section.

```
aws cloudformation create-stack --stack-name IAM-Policy-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

The command above creates the IAM user (including the permissions boundary and the identity-based policy) as well as the S3 buckets (including the bucket policies). The names of the S3 buckets as well as the name of the IAM user must be specified as template parameters. The [stack-params.json](./stack-params.json) file contains parameter values used during my experiments.
