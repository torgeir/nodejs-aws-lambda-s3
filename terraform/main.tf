provider "aws" {
  region  = "eu-west-1"
  profile = "privat"
}

# an s3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "js-plattform-faggruppe-bucket"
  acl    = "private" 
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"js-plattform-faggruppe-bucket-read-only",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::js-plattform-faggruppe-bucket/*"]
    }
  ]
}
EOF
}

# create a lambda
resource "aws_lambda_function" "lambda" {
  function_name    = "js_plattform_faggruppe"
  handler          = "index.handler"
  runtime          = "nodejs6.10"
  filename         = "function.zip"
  source_code_hash = "${base64sha256(file("function.zip"))}"
  role             = "${aws_iam_role.lambda_exec_role.arn}"
}

# role for the lambda to assume
resource "aws_iam_role" "lambda_exec_role" {
  name = "js_plattform_faggruppe_lambda_exec_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# a policy for the role the lambda assumes, allowing logs
# to be written to cloudwatch
resource "aws_iam_role_policy" "lambda_exec_role_policy" {
  name = "js_plattform_faggruppe_lambda_exec_role_policy"
  role = "${aws_iam_role.lambda_exec_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["logs:*"],
      "Effect": "Allow",
      "Resource": ["arn:aws:logs:*:*:*"]
    }
  ]
}
EOF
}

# call the lambda on s3 bucket upload
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket.id}"
  lambda_function {
    lambda_function_arn = "${aws_lambda_function.lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

# allow triggering the lambda from s3
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.bucket.arn}"
}

