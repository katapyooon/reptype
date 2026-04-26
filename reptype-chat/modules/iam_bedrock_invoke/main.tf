data "aws_region" "current" {}

# Rails アプリから Bedrock モデルを呼び出すための IAM ポリシー
# - Titan Embed Text V2: ドキュメント・クエリの埋め込み生成
# - Claude Haiku 4.5: チャット回答生成（ap-northeast-1ではjp.プレフィックスの推論プロファイル経由）
resource "aws_iam_policy" "bedrock_invoke" {
  name        = "${var.project_name}-bedrock-invoke-${var.environment}"
  description = "Rails アプリ向け Bedrock InvokeModel 権限（Titan Embed + Claude Haiku 4.5）"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["bedrock:InvokeModel"]
        Resource = [
          "arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/amazon.titan-embed-text-v2:0",
          "arn:aws:bedrock:${data.aws_region.current.region}:*:inference-profile/jp.anthropic.claude-haiku-4-5-20251001-v1:0"
        ]
      }
    ]
  })
}
