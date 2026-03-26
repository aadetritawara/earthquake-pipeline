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