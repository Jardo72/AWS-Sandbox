# S3 Replication Demo

## Introduction
Demonstration of S3 replication. The deployment involves two S3 buckets and an IAM role needed for the replication. Objects from one bucket are automatically replicated to the other bucket.

## Deployment
The project involves a CloudFormation template [cloud-formation-template.yml](./cloud-formation-template.yml) that can be used to provision all the AWS resources comprising the above described setup. The following AWS CLI command illustrates how to use the CloudFormation template to create the stack described in the previous section.

```
aws cloudformation create-stack --stack-name S3-Replication-Demo --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

Before deleting the stack, do not forget to remove all objects from all buckets. Otherwise, the removal of the stack will fail.
