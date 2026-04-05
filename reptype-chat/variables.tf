variable "project_name" {
  description = "プロジェクト名（リソース命名に使用）"
  type        = string
  default     = "reptype"
}

variable "environment" {
  description = "環境名"
  type        = string
  default     = "production"
}

variable "embedding_model_id" {
  description = "Bedrock 埋め込みモデル ID"
  type        = string
  # Titan Embeddings V2: 1024次元、日本語対応
  default     = "amazon.titan-embed-text-v2:0"
}

variable "vector_dimension" {
  description = "埋め込みベクトルの次元数（モデルに合わせること）"
  type        = number
  default     = 1024 # Titan Embeddings V2 の次元数
}
