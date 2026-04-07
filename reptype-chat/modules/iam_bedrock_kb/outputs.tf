output "role_arn" {
  description = "Bedrock Knowledge Base 用 IAM ロール ARN（次ステップの Knowledge Base 作成時に使用）"
  value       = aws_iam_role.bedrock_kb.arn
}

output "role_name" {
  description = "IAM ロール名"
  value       = aws_iam_role.bedrock_kb.name
}
