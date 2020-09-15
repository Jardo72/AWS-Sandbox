# S3 Bucket for Deployment of Applications

## Introduction
The AWS Sandbox involves several demo applications that are to be deployed to EC2 instances. For such applications, boostrapping based on EC2 user data is used. As part of the bootstrapping, artifacts like JAR files have to be copied to EC2 instances. For these purposes, an S3 bucket is used. After a successful build of such an artifact, you have to copy the artifact to the above mentioned S3 bucket. The bootstrapping will then copy the artifact from the S3 bucket to the EC2 instance.

This document provides AWS CLI commands that:
- create the above described S3 bucket
- create an IAM policy that allows download of objects from the above described S3 bucket
- create an IAM role which is to be assigned to EC2 instances so that bootstrapping will be able to download objects from the above described S3 bucket

## Setup
All sections within this chapter of this document assume that your AWS CLI has been configured via the `aws configure` command so that the default region has been set to the AWS region where you want to create the S3 bucket (IAM roles and policies are global).

### S3 Bucket
Choose a unique name for your bucket and replace the `<bucket-name>` placeholder in the commands below with the chosen bucket name.

```bash
# create a new S3 bucket
aws s3 mb s3://<bucket-name>

# make the S3 bucket private (i.e. prevent public anonymous access)
aws s3api put-bucket-acl --bucket <bucket-name> --acl private
```

For my bucket, I use the name `jardo72-ec2-installation-repo`, which leads to the following commands:
```bash
aws s3 mb s3://jardo72-ec2-installation-repo
aws s3api put-bucket-acl --bucket jardo72-ec2-installation-repo --acl private
```

The following command can be used to list all objects stored in the bucket (do not forget to replace the `<bucket-name>` placeholder):
```bash
aws s3 ls s3://<bucket-name> --recursive
```

### IAM Policy
Create a JSON file with the following content and do not forget to replace the `<bucket-name>` placeholder with the name of the S3 bucket used in the previous section. This JSON structure represents an IAM policy that allows to download S3 objects from the S3 bucket.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::<bucket-name>/*"
        }
    ]
}
```

In my case (I use the `jardo72-ec2-installation-repo` S3 bucket), the policy looks like depicted by the following JSON snippet:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::jardo72-ec2-installation-repo/*"
        }
    ]
}
```

The following AWS CLI command uses the above described policy document to create a new IAM policy.
```bash
# create an IAM policy that can be used to grant the EC2 instances permission to download files from the S3 bucket
aws iam create-policy --policy-name <policy-name> --policy-document file://<json-file-name>
```

As I use the name `EC2InstallationRepoReadAccess` for the IAM policy, and I store the policy document in the file `S3-policy.json` residing in the directory used as current directory when executing the AWS CLI `create-policy` command, I use the following command:
```bash
aws iam create-policy --policy-name EC2InstallationRepoReadAccess --policy-document file://./S3-policy.json
```

The following commands can be used to retrieve details about the created policy (do not forget to replace the `<policy-ARN>` placeholder). The second of the commands assumes the policy has not been modified yet, so version 1 is the latest version.
```bash
aws iam get-policy --policy-arn <policy-ARN>
aws iam get-policy-version --policy-arn <policy-ARN> --version-id v1
```

### IAM Role
TODO

## Cleanup
The following sequence of commands can be used to clean up resources created above. Do not forget to replace the placeholders (`<bucket-name>` and `<policy-ARN>`) with the actual identifiers of your resources.
```bash
# delete the IAM policy
aws iam delete-policy --policy-arn <policy-ARN>

# empty the S3 bucket (i.e. remove all objects from the S3 bucket)
aws s3 rm s3://<bucket-name> --recursive

# remove the S3 bucket (it must be empty)
aws s3 rb s3://<bucket-name>
```
