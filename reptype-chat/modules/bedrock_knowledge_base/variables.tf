variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名（stg / prd）"
  type        = string
}

variable "kb_role_arn" {
  description = "Bedrock Knowledge Base 用 IAM ロール ARN"
  type        = string
}

variable "vector_index_arn" {
  description = "S3 Vectors インデックス ARN"
  type        = string
}

variable "documents_bucket_arn" {
  description = "ドキュメント用 S3 バケット ARN"
  type        = string
}
