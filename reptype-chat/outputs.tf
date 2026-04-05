output "knowledge_base_id" {
  description = "Bedrock Knowledge Base ID（API 呼び出し時に使用）"
  value       = aws_bedrockagent_knowledge_base.main.id
}

output "knowledge_base_arn" {
  description = "Bedrock Knowledge Base ARN"
  value       = aws_bedrockagent_knowledge_base.main.arn
}

output "data_source_id" {
  description = "データソース ID（同期実行時に使用）"
  value       = aws_bedrockagent_data_source.s3_documents.data_source_id
}

output "documents_bucket_name" {
  description = "ドキュメントをアップロードする S3 バケット名"
  value       = aws_s3_bucket.kb_documents.bucket
}

output "vector_bucket_name" {
  description = "S3 Vectors バケット名"
  value       = aws_s3vectors_vector_bucket.kb_vectors.name
}
