# 

## Introduction
- Lambda function used as event handler for S3 event notifications
- files uploaded to an S3 bucket representing results of ice hockey games
- upload of such a file triggers the Lambda function which parses the game results, calculates standings based on the parsed game results, and sends the calculated standings to an SQS queue

## Source Code Organization and Build


## Deployment
- compress all Python files to a single flat ZIP file (no directory structure)
- upload to an S3 bucket
- use CloudFormation to deploy

```
aws cloudformation create-stack --stack-name Lambda-Ice-Hockey --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

TODO:
- there is no notification configuration - this must be created manually
- it seems that this cannot be done directly via CloudFormation - there seems to be a problem with cyclic dependencies
- however, it seems that CloudFormation can create a Lambda function that will configure the S3 event notification
- see https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-bucket-notificationconfig.html
- see https://aws.amazon.com/premiumsupport/knowledge-center/cloudformation-s3-notification-lambda/

## Functionality
- input data format
- standings calculation (env. variables as configuration, tie breaking in case of equal points)
- standings format
- test data
