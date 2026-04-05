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
