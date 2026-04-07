output "vector_bucket_name" {
  description = "S3 Vectors バケット名"
  value       = aws_s3vectors_vector_bucket.main.vector_bucket_name
}

output "vector_bucket_arn" {
  description = "S3 Vectors バケット ARN"
  value       = "arn:aws:s3vectors:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bucket/${aws_s3vectors_vector_bucket.main.vector_bucket_name}"
}

output "index_name" {
  description = "ベクトルインデックス名"
  value       = aws_s3vectors_index.main.index_name
}

output "index_arn" {
  description = "ベクトルインデックス ARN"
  value       = "arn:aws:s3vectors:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bucket/${aws_s3vectors_vector_bucket.main.vector_bucket_name}/index/${aws_s3vectors_index.main.index_name}"
}


