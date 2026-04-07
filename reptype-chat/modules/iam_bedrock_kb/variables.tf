variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名（stg / prd）"
  type        = string
}

variable "documents_bucket_arn" {
  description = "ドキュメント用 S3 バケットの ARN"
  type        = string
}

variable "vector_bucket_arn" {
  description = "S3 Vectors バケットの ARN"
  type        = string
}

variable "vector_index_arn" {
  description = "S3 Vectors インデックスの ARN"
  type        = string
}
