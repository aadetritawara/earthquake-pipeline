provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "seismic_raw_data" {
  bucket = "earthquake-pipeline-project-03-2026" 

  tags = {
    Name        = "Seismic Raw Data"
    Environment = "Dev"
  }
}

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