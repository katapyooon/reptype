output "knowledge_base_id" {
  description = "Knowledge Base ID（同期実行・Rails アプリからの検索クエリに使用）"
  value       = aws_bedrockagent_knowledge_base.main.id
}

output "knowledge_base_arn" {
  description = "Knowledge Base ARN"
  value       = aws_bedrockagent_knowledge_base.main.arn
}

output "data_source_id" {
  description = "Data Source ID（同期実行時に使用）"
  value       = aws_bedrockagent_data_source.s3.data_source_id
}
