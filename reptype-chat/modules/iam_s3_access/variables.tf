variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名（stg / prd）"
  type        = string
}

variable "bucket_arn" {
  description = "アクセスを許可する S3 バケット ARN"
  type        = string
}
