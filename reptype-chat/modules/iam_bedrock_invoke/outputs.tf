output "policy_arn" {
  description = "Bedrock InvokeModel 用 IAM ポリシー ARN（Rails アプリの実行ロールにアタッチする）"
  value       = aws_iam_policy.bedrock_invoke.arn
}
