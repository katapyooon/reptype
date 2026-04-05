module "s3_storage" {
  source = "../../modules/s3_storage"

  project_name = "reptype"
  environment  = "stg"
}

output "documents_bucket_name" {
  description = "ドキュメントをアップロードする S3 バケット名"
  value       = module.s3_storage.bucket_name
}
