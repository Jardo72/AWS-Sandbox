# DynamoDB Sandbox
Simple DynamoDB sandbox with a bunch of AWS CLI commands that create a DynamoDB table, populate it with some data and execute some scans. Some of the CLI commands use supplementary JSON files which are part of this project.

```
# create the table
aws dynamodb create-table --table-name Catalogue --attribute-definitions AttributeName=articleId,AttributeType=S --key-schema AttributeName=articleId,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# populate it with data
aws dynamodb batch-write-item --request-items file://catalogue-items.json

# basic scan
aws dynamodb scan --table-name Catalogue

# basic scan enhanced with information about the consumed capacity
aws dynamodb scan --table-name Catalogue --return-consumed-capacity TOTAL

# basic scan with limit for the number of items to be returned in the command's output (which can contain the next-token if more items are available)
aws dynamodb scan --table-name Catalogue --max-items 10

# scan with projection expression
aws dynamodb scan --table-name Catalogue --projection-expression "articleId,vendor,category,productName,price"

# scan with filter expression
aws dynamodb scan --table-name Catalogue --filter-expression "category = :category" --expression-attribute-values file://CPU-filter.json

# scan with another filter expression
aws dynamodb scan --table-name Catalogue --filter-expression "category = :category and price >= :minPrice" --expression-attribute-values file://expensive-GPU-filter.json
```
