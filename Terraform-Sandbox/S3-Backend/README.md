# S3 Backend Demo
Simple Terraform configuration demonstrating an AWS S3 bucket as Terraform backend (remote store for Terraform state, without state locking). Before you try to use this configuration, you will have to change the backend configuration. The current configuration relies on an S3 bucket which existes in my AWS account, and the bucket is not publicly accessible. In other words, this configuration will not work unless you have access to the S3 bucket in my account. However, you can simply change the `backend` element within the `terraform` block and use an S3 bucket which is accessible.

```
terraform apply -auto-approve

terraform apply -auto-approve -var="create_extra_iam_user=false"
```
