output "policy_arn" {
  description = "S3 アクセス用 IAM ポリシー ARN（Rails アプリの実行ロールにアタッチする）"
  value       = aws_iam_policy.s3_access.arn
}
