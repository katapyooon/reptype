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

module "iam_s3_access" {
  source = "../../modules/iam_s3_access"

  project_name = "reptype"
  environment  = "prd"
  bucket_arn   = module.s3_storage.bucket_arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_bedrock" {
  role       = "ecsTaskRole"
  policy_arn = module.iam_bedrock_invoke.policy_arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3" {
  role       = "ecsTaskRole"
  policy_arn = module.iam_s3_access.policy_arn
}

output "documents_bucket_name" {
  description = "ドキュメントをアップロードする S3 バケット名"
  value       = module.s3_storage.bucket_name
}

output "bedrock_invoke_policy_arn" {
  description = "Bedrock InvokeModel 用 IAM ポリシー ARN"
  value       = module.iam_bedrock_invoke.policy_arn
}

output "s3_access_policy_arn" {
  description = "S3 アクセス用 IAM ポリシー ARN"
  value       = module.iam_s3_access.policy_arn
}
