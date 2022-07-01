# S3 Backend Demo
Simple Terraform configuration demonstrating an AWS S3 bucket as Terraform backend (remote store for Terraform state, without state locking). As I did not want to hardcode the name of the S3 bucket and other backend settings into the Terraform configuration, this demo uses partial backend configuration. Therefore, you have to specify the backend configuration properties when executing `terraform init` as illustrated by the following command:

```
terraform init -backend-config=config.s3.tfbackend
```

The following snippet illustrates the contents of the `config.s3.tfbackend` file used during my experiments (you would have to use a bucket you have access to):

```
bucket = "jardo72-terraform-state"
key    = "terraform-sandbox/s3-backend/terraform.tfstate"
region = "eu-central-1"
```

The configuration only creates few IAM resources (IAM users, IAM groups, IAM policies). All input variables have default values, so you do not need any `.tfvars` file to apply the configuration. One of the variables controls whether one of the IAM users will be created or not. The following snippet illustrates how to overwrite the default value for the variable from the command line:

```
terraform apply -auto-approve -var="create_extra_iam_user=false"
```
