module "s3_storage" {
  source = "../../modules/s3_storage"

  project_name = "reptype"
  environment  = "prd"
}

module "iam_bedrock_invoke" {
  source = "../../modules/iam_bedrock_invoke"

  project_name = "reptype"
  environment  = "prd"
}

output "documents_bucket_name" {
  description = "ドキュメントをアップロードする S3 バケット名"
  value       = module.s3_storage.bucket_name
}

output "bedrock_invoke_policy_arn" {
  description = "Bedrock InvokeModel 用 IAM ポリシー ARN（Rails アプリの実行ロールにアタッチする）"
  value       = module.iam_bedrock_invoke.policy_arn
}
