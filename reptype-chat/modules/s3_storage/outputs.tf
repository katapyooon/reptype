output "bucket_name" {
  description = "ドキュメントをアップロードする S3 バケット名"
  value       = aws_s3_bucket.kb_documents.bucket
}

output "bucket_arn" {
  description = "S3 バケット ARN（将来 Bedrock Knowledge Base に渡す）"
  value       = aws_s3_bucket.kb_documents.arn
}
