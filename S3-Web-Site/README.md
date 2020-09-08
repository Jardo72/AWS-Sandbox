# S3 Static Website Hosting Demo

## Introduction
This project is just a small set of files that can be used to demonstrate the static website hosting provided by AWS S3.

## How to Setup the Static Website Hosted by AWS S3
The following sequence of AWS CLI commands can be used to setup a static website comprised of the HTML file provided by this project. Obviously, you have to choose a uniqe name for your S3 bucket, and replace the `<bucket-name>` placeholder in the commands below with the chosen bucket name.
```
# create a new S3 bucket
aws s3 mb s3://<bucket-name>

# upload the HTML files to the S3 bucket created above
aws s3 cp index.html s3://<bucket-name>/index.html
aws s3 cp linked-file.html s3://<bucket-name>/linked-file.html
aws s3 cp error.html s3://<bucket-name>/error.html

# enable public anonymous read-only access to all files stored in the S3 bucket created above
aws s3api put-bucket-acl --bucket <bucket-name> --acl public-read
aws s3 website s3://<bucket-name> --index-document index.html --error-document error.html
```

The following pair of commands can be used to check the website.
```
# list the contents of the S3 bucket
aws s3 ls s3://<bucket-name>

# display the configuration of the website (index and error page settings)
aws s3api get-bucket-website --bucket <bucket-name>
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
