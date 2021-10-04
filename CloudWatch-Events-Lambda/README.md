# CloudWatch Events with Scheduled Lambda Function
Simple demonstration of CloudWatch Events rule with schedule expression serving as trigger for a Lambda function which is automatically invoked every minute. The entire demo is implemented as a simple [CloudFormation template](./cloud-formation-template.yml) which also involves the Python code for the Lambda function. The template has no paramaters, so the deployment via AWS CLI is very simple:

```
aws cloudformation create-stack --stack-name CloudWatch-Events-Lambda --template-body file://cloud-formation-template.yml --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```
