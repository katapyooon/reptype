class BedrockChatService
  # Amazon Nova Lite (v1) US クロスリージョン推論プロファイル
  # Nova の AP プロファイルは未対応のため US プロファイルを使用
  MODEL_ID = "us.amazon.nova-lite-v1:0"
  MAX_TOKENS = 1024

  SYSTEM_PROMPT = <<~PROMPT
    あなたは爬虫類の飼育に詳しいアドバイザーです。
    ユーザーから爬虫類に関する質問を受け取ったら、提供された参考情報をもとに、
    わかりやすく丁寧に日本語で答えてください。
    参考情報に含まれていない内容については、その旨を正直に伝えてください。
  PROMPT

  def initialize
    @client = Aws::BedrockRuntime::Client.new
  end

  # 取得したチャンクと質問を Nova に渡して回答を生成する
  # @param question [String] ユーザーの質問
  # @param chunks [Array<DocumentChunk>] RAG で取得した関連チャンク
  # @return [String] Nova の回答
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
        system: [ { text: SYSTEM_PROMPT } ],
        messages: [
          {
            role: "user",
            content: [ { text: user_message } ]
          }
        ],
        inferenceConfig: {
          maxNewTokens: MAX_TOKENS
        }
      }.to_json
    )

    body = JSON.parse(response.body.read)
    body.dig("output", "message", "content", 0, "text")
  end
end
