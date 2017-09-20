# nodejs-aws-lambda-s3

Example repo showing how to use terraform to deploy a node.js aws lambda that handles file uploads from s3

## deploy to aws using terraform

- zip up the lambda 
- create the lambda
- create an s3 bucket with read only permissions
- create a lambda execution role, that the lambda takes when running
- create a lambda policy for the role, that allows the lambda to create log streams and write logs to cloudwatch
- create an s3 bucket trigger to call the lambda when new objects are created
- create a permission to allow for s3 to trigger the lambda

```sh
npm run aws:deploy
```

## destroy what terraform created

tear down all of the infrastructure that was created when deploying.

```sh
npm run aws:destroy
```
