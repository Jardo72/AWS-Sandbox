# API Gateway + Lambda Demo

## Introduction

# Manual Testing

`GET `

`POST /kms/encrypt`
```json
{
    "plaintext": "Hello world!!!",
    "kmsKeyId": "a48a7295-7b9a-421a-9ba0-c6a78e39f873"
}
```

`POST /kms/decrypt`
```json
{
    "ciphertext": "AQICAHjWFp6RqVrJNjLbt2QWVzq2HLNk7wzp43c72NxPyxG6eQE+y8Tf+vVho4NZsgJhJGd6AAAAcjBwBgkqhkiG9w0BBwagYzBhAgEAMFwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMT64F5yW563mmONU6AgEQgC+u/yMj+zBbniFLjMW/yyxbW9aQ2psj9XY2jparsRcWFtpe1vB4p1sOJ2KArAIZjA==",
    "kmsKeyId": "a48a7295-7b9a-421a-9ba0-c6a78e39f873"
}
```


## Automated Tests
