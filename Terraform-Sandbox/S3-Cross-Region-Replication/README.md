# S3 Cross-Region Replication Demo
Simple demonstration of S3 cross-region replication. The Terraform configuration illustrates usage of modules in combination with several providers. As the source S3 bucket and the destination S3 bucket are provisioned in different AWS regions, the configuration requires at least two providers, and they must be passed to the module responsible for provisioning of S3 buckets.

The following snippet illustrates the values of input variables used during my experiments:

```hcl
source_bucket_details = {
  bucket_name = "jardo72-crr-source-bucket"
  aws_region  = "eu-central-1"
}

destination_bucket_details = {
  bucket_name = "jardo72-crr-destination-bucket"
  aws_region  = "eu-north-1"
}

tags = {
  Stack         = "S3-CRR-Demo",
  ProvisionedBy = "Terraform"
}
```