provider "aws" {
  region = "us-east-1"
}

# S3 bucket to store raw seismic data
resource "aws_s3_bucket" "seismic_raw_data" {
  bucket = "earthquake-pipeline-project-03-2026"

  tags = {
    Name        = "Seismic Raw Data"
    Environment = "Dev"
  }
}

# Block all public access to the bucket for security
resource "aws_s3_bucket_public_access_block" "seismic_raw_data_secure" {
  bucket = aws_s3_bucket.seismic_raw_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Allow AWS Lambda to assume this role
resource "aws_iam_role" "lambda_exec_role" {
  name = "seismic_lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Policy to allow putting files into seismic bucket
resource "aws_iam_policy" "lambda_s3_write_policy" {
  name        = "seismic_lambda_s3_write_policy"
  description = "Allows Lambda to write raw earthquake data to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "s3:PutObject"
      Effect   = "Allow"
      Resource = "${aws_s3_bucket.seismic_raw_data.arn}/*"
    }]
  })
}

# Attach policy to the lamda role so it can write to bucket
resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_write_policy.arn
}

# Attach AWS managed policy so Lambda can write print statements to CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Compress Python code every time Terraform runs 
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "seismic_ingest.py"
  output_path = "seismic_ingest.zip"
}

# Lambda Function to fetch seismic data and store in S3
resource "aws_lambda_function" "seismic_fetcher" {
  function_name = "seismic-data-fetcher"

  role             = aws_iam_role.lambda_exec_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.12"
  handler          = "seismic_ingest.lambda_handler"
  timeout          = 15

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.seismic_raw_data.bucket
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_15_minutes" {
  name                = "trigger-seismic-lambda-15-minutes"
  description         = "Fires every 15 minutes to trigger the seismic data fetcher"
  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.every_15_minutes.name
  target_id = "SeismicLambdaFunction"
  arn       = aws_lambda_function.seismic_fetcher.arn
}

# Give event bridge permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.seismic_fetcher.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_15_minutes.arn
}