variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名（stg / prd）"
  type        = string
}

variable "account_id" {
  description = "AWS アカウント ID（バケット名の一意性確保に使用）"
  type        = string
}
