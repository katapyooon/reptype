data "aws_region" "current" {}

# Rails アプリから Bedrock モデルを呼び出すための IAM ポリシー
# - Titan Embed Text V2: ドキュメント・クエリの埋め込み生成
# - Claude 3.5 Sonnet / Haiku: チャット回答生成
resource "aws_iam_policy" "bedrock_invoke" {
  name        = "${var.project_name}-bedrock-invoke-${var.environment}"
  description = "Rails アプリ向け Bedrock InvokeModel 権限（Titan Embed + Titan Text）"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["bedrock:InvokeModel"]
        Resource = [
          "arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/amazon.titan-embed-text-v2:0",
          "arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/amazon.titan-text-express-v1"
        ]
      }
    ]
  })
}
