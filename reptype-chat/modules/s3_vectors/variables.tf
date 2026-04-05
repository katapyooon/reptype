variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名（stg / prd）"
  type        = string
}

variable "vector_dimension" {
  description = "埋め込みベクトルの次元数（モデルに合わせること）"
  type        = number
  default     = 1024 # amazon.titan-embed-text-v2:0 の次元数
}
