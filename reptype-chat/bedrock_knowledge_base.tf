# Bedrock Knowledge Base 本体
resource "aws_bedrockagent_knowledge_base" "main" {
  name        = "${var.project_name}-knowledge-base"
  description = "reptype アプリケーション向け Knowledge Base（S3 Vectors バックエンド）"
  role_arn    = aws_iam_role.bedrock_kb.arn

  # ベクトル検索設定：埋め込みモデルを指定
  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model_id}"
    }
  }

  # ベクトル保存先に S3 Vectors を指定
  storage_configuration {
    type = "S3_VECTORS"
    s3_vectors_configuration {
      vector_bucket_arn = aws_s3vectors_vector_bucket.kb_vectors.arn
      index_arn         = aws_s3vectors_index.kb_index.arn
    }
  }

  depends_on = [
    aws_iam_role_policy.bedrock_kb_s3,
    aws_iam_role_policy.bedrock_kb_s3vectors,
    aws_iam_role_policy.bedrock_kb_model
  ]
}

# データソース：S3 バケット内のドキュメントを Knowledge Base に接続
resource "aws_bedrockagent_data_source" "s3_documents" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.main.id
  name              = "${var.project_name}-s3-datasource"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.kb_documents.arn
    }
  }

  # チャンク戦略：デフォルト（300トークン、20%オーバーラップ）
  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens         = 300
        overlap_percentage = 20
      }
    }
  }
}
