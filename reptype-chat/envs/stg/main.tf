module "s3_storage" {
  source = "../../modules/s3_storage"

  project_name = "reptype"
  environment  = "stg"
}

module "s3_vectors" {
  source = "../../modules/s3_vectors"

  project_name = "reptype"
  environment  = "stg"
  # vector_dimension のデフォルト値 1024 は amazon.titan-embed-text-v2:0 に対応
}

module "iam_bedrock_kb" {
  source = "../../modules/iam_bedrock_kb"

  project_name         = "reptype"
  environment          = "stg"
  documents_bucket_arn = module.s3_storage.bucket_arn
  vector_bucket_arn    = module.s3_vectors.vector_bucket_arn
  vector_index_arn     = module.s3_vectors.index_arn
}

module "bedrock_knowledge_base" {
  source = "../../modules/bedrock_knowledge_base"

  project_name         = "reptype"
  environment          = "stg"
  kb_role_arn          = module.iam_bedrock_kb.role_arn
  vector_index_arn     = module.s3_vectors.index_arn
  documents_bucket_arn = module.s3_storage.bucket_arn
}

output "knowledge_base_id" {
  description = "Knowledge Base ID（同期実行・検索クエリに使用）"
  value       = module.bedrock_knowledge_base.knowledge_base_id
}

output "data_source_id" {
  description = "Data Source ID（同期実行時に使用）"
  value       = module.bedrock_knowledge_base.data_source_id
}

output "bedrock_kb_role_arn" {
  description = "Bedrock Knowledge Base 用 IAM ロール ARN"
  value       = module.iam_bedrock_kb.role_arn
}

output "documents_bucket_name" {
  description = "ドキュメントをアップロードする S3 バケット名"
  value       = module.s3_storage.bucket_name
}

output "vector_bucket_name" {
  description = "S3 Vectors バケット名"
  value       = module.s3_vectors.vector_bucket_name
}

output "vector_index_name" {
  description = "ベクトルインデックス名"
  value       = module.s3_vectors.index_name
}
