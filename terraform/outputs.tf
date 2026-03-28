output "s3_bucket_name" {
  description = "The name of the S3 bucket for raw seismic data"
  value       = aws_s3_bucket.seismic_raw_data.bucket
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for IAM policies"
  value       = aws_s3_bucket.seismic_raw_data.arn
}

output "databricks_role_arn" {
  description = "The ARN of the IAM role for Databricks to access S3"
  value       = aws_iam_role.databricks_s3_role.arn
}