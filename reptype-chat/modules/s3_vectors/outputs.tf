output "vector_bucket_name" {
  description = "S3 Vectors バケット名"
  value       = aws_s3vectors_vector_bucket.main.vector_bucket_name
}


output "index_name" {
  description = "ベクトルインデックス名"
  value       = aws_s3vectors_index.main.index_name
}


