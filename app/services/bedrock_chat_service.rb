class BedrockChatService
  # Amazon Titan Text Express v1
  # 東京リージョン直接呼び出し・申請不要
  MODEL_ID = "amazon.titan-text-express-v1"
  MAX_TOKENS = 1024

  SYSTEM_PROMPT = <<~PROMPT.strip
    あなたは爬虫類の飼育に詳しいアドバイザーです。
    ユーザーから爬虫類に関する質問を受け取ったら、提供された参考情報をもとに、
    わかりやすく丁寧に日本語で答えてください。
    参考情報に含まれていない内容については、その旨を正直に伝えてください。
  PROMPT

  def initialize
    @client = Aws::BedrockRuntime::Client.new
  end

  # 取得したチャンクと質問を Titan に渡して回答を生成する
  # @param question [String] ユーザーの質問
  # @param chunks [Array<DocumentChunk>] RAG で取得した関連チャンク
  # @return [String] Titan の回答
  def call(question:, chunks:)
    context = chunks.map.with_index(1) { |chunk, i| "【参考#{i}】\n#{chunk.content}" }.join("\n\n")

    # Titan Text はシステムプロンプトを本文に含める
    input_text = <<~TEXT
      #{SYSTEM_PROMPT}

      以下の参考情報をもとに質問に答えてください。

      #{context}

      質問：#{question}

      回答：
    TEXT

    response = @client.invoke_model(
      model_id: MODEL_ID,
      content_type: "application/json",
      accept: "application/json",
      body: {
        inputText: input_text,
        textGenerationConfig: {
          maxTokenCount: MAX_TOKENS,
          temperature: 0.7,
          topP: 0.9
        }
      }.to_json
    )

    body = JSON.parse(response.body.read)
    body.dig("results", 0, "outputText")
  end
end
