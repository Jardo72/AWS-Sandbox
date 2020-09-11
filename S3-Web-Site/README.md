# S3 Static Website Hosting Demo

## Introduction
This project is just a small set of files that can be used to demonstrate the static website hosting provided by AWS S3.

## How to Setup the Static Website Hosted by AWS S3
Before starting with the actual setup, you have to choose a unique name for the S3 bucket. Create a file `bucket-policy.json` with the following content, and replace the `<bucket-name>` placeholder with the actual bucket name.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::<bucket-name>/*"
        }
    ]
}
```

The following sequence of AWS CLI commands can be used to setup a static website comprised of the HTML file provided by this project. Do not forget to replace the `<bucket-name>` placeholder in the commands below with the chosen bucket name. The commands assume that the root directory of this project is the current directory, and that the `bucket-policy.json` created above is also present in the current directory.
```
# create a new S3 bucket
aws s3 mb s3://<bucket-name>

# upload the HTML files to the S3 bucket created above
aws s3 cp index.html s3://<bucket-name>/index.html
aws s3 cp linked-file.html s3://<bucket-name>/linked-file.html
aws s3 cp error.html s3://<bucket-name>/error.html

# enable public anonymous read-only access to all files stored in the S3 bucket created above
aws s3api put-bucket-acl --bucket <bucket-name> --acl public-read
aws s3api put-bucket-policy --bucket <bucket-name> --policy file://./bucket-policy.json

# configure the website (index and error page)
aws s3 website s3://<bucket-name> --index-document index.html --error-document error.html
```

The following pair of commands can be used to check the website.
```
# list the contents of the S3 bucket
aws s3 ls s3://<bucket-name>

# display the configuration of the website (index and error page settings)
aws s3api get-bucket-website --bucket <bucket-name>

# display the bucket policy
aws s3api get-bucket-policy --bucket <bucket-name>
```

If the above listed AWS CLI commands succeeded, you should be able to access the website via one of the following URLs:
- `http://<bucket-name>.s3-website.<aws-region>.amazonaws.com`
- `http://<bucket-name>.s3-website.<aws-region>.amazonaws.com/index.html`

Do not forget to replace the `<bucket-name>` placeholder in the URLs above. In addition, you also have to replace the `<aws-region>` placeholder with the AWS region used by your AWS CLI. An attempt to access a non-existent URL like the following one should redirect you to the error page.
`http://<bucket-name>.s3-website.<aws-region>.amazonaws.com/no-such-file.html`

## How to Clean up the AWS Resources
The following sequence of AWS CLI commands can be used to clean up all AWS resources provisioned in the previous section. Obviously, you have to replace the `<bucket-name>` placeholder in the commands below with the bucket name used to setup the website.
```
# empty the S3 bucket (i.e. remove all objects from the S3 bucket)
aws s3 rm s3://<bucket-name> --recursive

# remove the S3 bucket (it must be empty)
aws s3 rb s3://<bucket-name>
```
