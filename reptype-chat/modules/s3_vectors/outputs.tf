output "vector_bucket_name" {
  description = "S3 Vectors バケット名"
  value       = aws_s3vectors_vector_bucket.main.name
}

output "vector_bucket_arn" {
  description = "S3 Vectors バケット ARN（将来 Bedrock Knowledge Base IAM ポリシーに渡す）"
  value       = aws_s3vectors_vector_bucket.main.arn
}

output "index_name" {
  description = "ベクトルインデックス名"
  value       = aws_s3vectors_index.main.name
}

output "index_arn" {
  description = "ベクトルインデックス ARN（将来 Bedrock Knowledge Base に渡す）"
  value       = aws_s3vectors_index.main.arn
}
