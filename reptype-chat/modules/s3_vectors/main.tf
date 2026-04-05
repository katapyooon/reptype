# S3 Vectors バケット（ベクトル埋め込みの格納先）
resource "aws_s3vectors_vector_bucket" "main" {
  name = "${var.project_name}-kb-vectors-${var.environment}-${var.account_id}"
}

# ベクトルインデックス
# distance_metric: cosine
#   - テキストの意味的な近さを角度で測定（長短に影響されない）
#   - RAG / セマンティック検索のユースケースに推奨
#   - amazon.titan-embed-text-v2:0 の正規化済みベクトルと相性が良い
resource "aws_s3vectors_index" "main" {
  vector_bucket_name = aws_s3vectors_vector_bucket.main.name
  name               = "${var.project_name}-kb-index-${var.environment}"
  data_type          = "float32"
  dimension          = var.vector_dimension
  distance_metric    = "cosine"
}
