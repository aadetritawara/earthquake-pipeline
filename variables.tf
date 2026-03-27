variable "aws_account_id" {
  description = "AWS account ID used in IAM role ARNs"
  type        = string
}

variable "databricks_account_id" {
  description = "Databricks account ID used in IAM trust policy"
  type        = string
}