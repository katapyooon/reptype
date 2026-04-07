data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Bedrock が引き受ける IAM ロール
resource "aws_iam_role" "bedrock_kb" {
  name = "${var.project_name}-bedrock-kb-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
          }
        }
      }
    ]
  })
}

# ドキュメント用 S3 バケットへの読み取り権限
resource "aws_iam_role_policy" "s3_documents" {
  name = "${var.project_name}-bedrock-kb-s3-${var.environment}"
  role = aws_iam_role.bedrock_kb.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.documents_bucket_arn,
          "${var.documents_bucket_arn}/*"
        ]
      }
    ]
  })
}

# S3 Vectors バケット・インデックスへのアクセス権限
resource "aws_iam_role_policy" "s3_vectors" {
  name = "${var.project_name}-bedrock-kb-s3vectors-${var.environment}"
  role = aws_iam_role.bedrock_kb.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3vectors:GetVectorBucket",
          "s3vectors:GetIndex",
          "s3vectors:PutVectors",
          "s3vectors:QueryVectors",
          "s3vectors:DeleteVectors"
        ]
        Resource = [
          var.vector_bucket_arn,
          var.vector_index_arn
        ]
      }
    ]
  })
}

# 埋め込みモデル（amazon.titan-embed-text-v2:0）呼び出し権限
resource "aws_iam_role_policy" "bedrock_model" {
  name = "${var.project_name}-bedrock-kb-model-${var.environment}"
  role = aws_iam_role.bedrock_kb.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
      }
    ]
  })
}
