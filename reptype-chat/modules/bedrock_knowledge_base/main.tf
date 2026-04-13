data "aws_region" "current" {}

# Bedrock Knowledge Base 本体
resource "aws_bedrockagent_knowledge_base" "main" {
  name        = "${var.project_name}-knowledge-base-${var.environment}"
  description = "爬虫類チャットボット向け Knowledge Base（${var.environment}）"
  role_arn    = var.kb_role_arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
    }
  }

  storage_configuration {
    type = "S3_VECTORS"
    s3_vectors_configuration {
      index_arn = var.vector_index_arn
    }
  }
}

# Data Source：S3 バケットのドキュメントを Knowledge Base に接続
resource "aws_bedrockagent_data_source" "s3" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.main.id
  name              = "${var.project_name}-s3-datasource-${var.environment}"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.documents_bucket_arn
    }
  }

  # チャンク戦略: 10トークン固定、オーバーラップなし
  # 日本語はJSONエスケープ(\uXXXX)で1文字6バイトになるため
  # S3 Vectorsのフィルタブルメタデータ上限（2048バイト）を超えないよう
  # 極小チャンクで動作検証する（検索品質の確認用）
  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens         = 10
        overlap_percentage = 0
      }
    }
  }
}
