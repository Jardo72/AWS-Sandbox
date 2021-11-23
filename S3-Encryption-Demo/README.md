# S3 Encryption Demo

## Introduction
Demonstration of S3 encryption, in particular:
* default bucket encryption
* bucket policies enforcing particular encryption method

The following table summarizes the setup.

| S3 Bucket                   | Default Encryption | Encryption Enforced by Bucket Policy | 
| --------------------------- | ------------------ | ------------------------------------ |
| DefaultKMSEncryptionBucket  | SSE-KMS            | None                                 |
| DefaultS3EncryptionBucket   | SSE-S3             | None                                 |
| EnforcedKMSEncryptionBucket | None               | SSE-KMS                              |
| EnforcedS3EncryptionBucket  | None               | SSE-S3                               |

## Deployment
The project involves a CloudFormation template ([cloud-formation-template.yml](./cloud-formation-template.yml)) that can be used to provision all the AWS resources comprising the above described setup. The following AWS CLI command illustrates how to use the CloudFormation template to create the stack described in the previous section.

```
aws cloudformation create-stack --stack-name S3-Encryption-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --on-failure ROLLBACK
```

The names of the S3 buckets as well as the ARN of the KMS key for the SSE-KMS encryption must be specified as template parameters. The [stack-params.json](./stack-params.json) file contains parameter values used during my experiments.
