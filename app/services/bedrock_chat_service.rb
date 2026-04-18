class BedrockChatService
  # Claude 3 Haiku: ap-northeast-1 で安定して利用可能
  # Sonnet 系は v1 が Legacy 化・v2 が ap. プロファイル未対応のため Haiku で検証
  MODEL_ID = "anthropic.claude-3-haiku-20240307-v1:0"
  MAX_TOKENS = 1024

  SYSTEM_PROMPT = <<~PROMPT
    あなたは爬虫類の飼育に詳しいキャラクターです。
    「〜だよ！」「〜だね！」「〜かな？」のようなフレンドリーなタメ口で話してください。
    「です・ます」は使わず、友達に話しかけるように答えてください。
    参考情報に含まれていない内容は「それはちょっとわからないな〜」のように正直に伝えてください。
  PROMPT

  def initialize
    @client = Aws::BedrockRuntime::Client.new
  end

  # 取得したチャンクと質問を Claude に渡して回答を生成する
  # @param question [String] ユーザーの質問
  # @param chunks [Array<DocumentChunk>] RAG で取得した関連チャンク
  # @return [String] Claude の回答
  def call(question:, chunks:)
    context = chunks.map.with_index(1) { |chunk, i| "【参考#{i}】\n#{chunk.content}" }.join("\n\n")

    user_message = <<~MESSAGE
      以下の参考情報をもとに質問に答えてください。

      #{context}

      質問：#{question}
    MESSAGE

    response = @client.invoke_model(
      model_id: MODEL_ID,
      content_type: "application/json",
      accept: "application/json",
      body: {
        anthropic_version: "bedrock-2023-05-31",
        max_tokens: MAX_TOKENS,
        system: SYSTEM_PROMPT,
        messages: [
          { role: "user", content: user_message }
        ]
      }.to_json
    )

    body = JSON.parse(response.body.read)
    body.dig("content", 0, "text")
  end
end
