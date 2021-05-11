# DynamoDB Sandbox
Simple DynamoDB sandbox with a bunh of AWS CLI commands that create a DynamoDB table, populate it with some data and execute some scans. Some of the CLI commands use supplementary JSON files which are part of this project.

```
aws dynamodb create-table --table-name Catalogue --attribute-definitions AttributeName=articleId,AttributeType=S --key-schema AttributeName=articleId,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

aws dynamodb batch-write-item --request-items file://catalogue-items.json

aws dynamodb scan --table-name Catalogue

aws dynamodb scan --table-name Catalogue --return-consumed-capacity TOTAL

aws dynamodb scan --table-name Catalogue --max-items 10

aws dynamodb scan --table-name Catalogue --projection-expression "articleId,vendor,category,productName,price"

aws dynamodb scan --table-name Catalogue --filter-expression "category = :category" --expression-attribute-values file://CPU-filter.json

aws dynamodb scan --table-name Catalogue --filter-expression "category = :category and price >= :minPrice" --expression-attribute-values file://expensive-GPU-filter.json
```
