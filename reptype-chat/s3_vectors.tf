# S3 Vectors バケット（ベクトル埋め込みの保存先）
# 従来の OpenSearch Serverless より低コストで Knowledge Base と直接統合可能
resource "aws_s3vectors_vector_bucket" "kb_vectors" {
  name = "${var.project_name}-kb-vectors"
}

# ベクトルインデックス（Knowledge Base が使用する検索インデックス）
resource "aws_s3vectors_index" "kb_index" {
  vector_bucket_name = aws_s3vectors_vector_bucket.kb_vectors.name
  name               = "${var.project_name}-kb-index"
  data_type          = "float32"
  dimension          = var.vector_dimension
  distance_metric    = "cosine" # コサイン類似度（テキスト検索に推奨）
}
