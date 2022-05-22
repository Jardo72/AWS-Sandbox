# Terraform Variables
Simple demonstration of Terraform variables of various data types including collections. Besides the `terraform.tfvars` file with variable values, this project also invokves `alternative.tfvars` file with alternative variable values, so you can try to specify tfvars file via the `-var-file` argument when starting the `terraform apply` command.

```bash
# use the default terraform.tfvars file 
tarraform apply -auto-approve

# use the alternative alternative.tfvars file
tarraform apply -auto-approve -var-file=alternative.tfvars
```