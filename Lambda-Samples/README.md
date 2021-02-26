# Lambda Samples

## Introduction
Lambda Samples is an experimantal/educational project meant as illustration of Lamdba functions. The project actually involves three Lambda functions:
- [dump-invocation](./dump-invocation.py)
- [read-secret-string](./read-secret-string.py)
- [read-ssm-parameter](./read-ssm-parameter.py)

Besides the above listed Lambda functions, the project also involves a CloudFormation template that can be used to create the above listed functions in AWS, together with other related AWS resources used by the functions.

## Deployment to AWS
As mentioned above, the project involves a CloudFormation template that can be used to deploy the Lambda functions to AWS. The template also creates:
- other resources (SSM parameter, secret in a secrets manager) accessed by the functions
- IAM roles (and the corresponding IAM policies) used as execution roles for the functions

In order to create a CloudFormation stack based on the template, follow these steps:
1. For each of the Python files, create a ZIP archive and upload it to an S3 bucket.
2. Use the [cloud-formation-template.yml](./cloud-formation-template.yml) file to create a new CloudFormation stack. The template is parametrized, so you will have to specify a bunch of values like the S3 bucket and the S3 object keys for the zipped Python files, the name and the value for the SSM parameter as well as for the secret etc. The parameters are described in the template.

The template can be used to create the stack via AWC Management Console, but it can also be used with AWS CLI. The following command illustrates the CLI approach.
```
aws cloudformation create-stack --stack-name Lambda-Samples --template-body file://cloud-formation-template.yml --parameters file://stack-params.json --capabilities CAPABILITY_NAMED_IAM --on-failure ROLLBACK
```

The [stack-params.json](./stack-params.json) file contains parameter values used during my experiments.

## Invocation of the Functions

### Dump Invocation
The following command illustrates how to invoke the [dump-invocation](./dump-invocation.py) function via the AWS CLI (the `--function-name` argument assumes you have deployed the functions via the above described CloudFormation template). The value of the `--payload` argument should be a Base64-encoded JSON structure carrying the input for the function. The return value of the function will be written to the `dump-invocation-response.json` file.
```
aws lambda invoke --function-name DumpInvocation --payload <base64-encoded-json> dump-invocation-response.json
```

The value of the `--payload` argument must be a Base64-encoded JSON structure. The function does not rely on any particular input, it simply dumps the input (together with other information) to the return value. Any JSON structure (even an empty one) can be used. The following snippet illustrates a structure used during my experiments.
```json
{
    "string": "Hello from Lambda",
    "number": 123,
    "boolean": true
}
```

### Read Secret String
The following command illustrates how to invoke the [read-secret-string](./read-secret-string.py) function via the AWS CLI (the `--function-name` argument assumes you have deployed the functions via the above described CloudFormation template).
```
aws lambda invoke --function-name ReadSecret --payload <base64-encoded-json> read-secret-response.json
```

The value of the `--payload` argument must be a Base64-encoded JSON structure illustrated by the following snippet. The `region` attribute must match with the AWS region where the secret which is to be read by the function resides. The `secret` attribute specifies the name of the secret to be read.
```json
{
    "region": "eu-central-1",
    "secret": "lambda-secret"
}
```

### Read SSM Parameter
The following command illustrates how to invoke the [read-ssm-parameter](./read-ssm-parameter.py) function via the AWS CLI (the `--function-name` argument assumes you have deployed the functions via the above described CloudFormation template).
```
aws lambda invoke --function-name ReadSSMParameter --payload <base64-encoded-json> read-ssm-param-response.json
```

The following snippet illustrates the JSON structure which in Base64-encoded form is to be used as value for the `--payload` argument. Obviously, the `region` attribute must match with the AWS region where the SSM parameter which is to be read by the function resides. The `parameter` attribute specifies the name of the parameter to be read.
```json
{
    "region": "eu-central-1",
    "parameter": "/lambda-samples/sample-param"
}
```
