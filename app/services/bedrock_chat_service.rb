class BedrockChatService
  MODEL_ID = "ap.anthropic.claude-haiku-4-5-20251001-v1:0"
  MAX_TOKENS = 1024

  def initialize
    @client = Aws::BedrockRuntime::Client.new
  end

  # 取得したチャンクと質問を Claude に渡して回答を生成する
  # @param question [String] ユーザーの質問
  # @param chunks [Array<DocumentChunk>] RAG で取得した関連チャンク
  # @param reptile_name [String] 対象の爬虫類の名前
  # @return [String] Claude の回答
  def call(question:, chunks:, reptile_name:)
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
        system: system_prompt(reptile_name),
        messages: [
          { role: "user", content: user_message }
        ]
      }.to_json
    )

    body = JSON.parse(response.body.read)
    body.dig("content", 0, "text")
  end

  private

  def system_prompt(reptile_name)
    <<~PROMPT
      あなたは#{reptile_name}の飼育に詳しいキャラクターです。
      「〜だよ！」「〜だね！」「〜かな？」のようなフレンドリーなタメ口で話してください。
      「です・ます」は使わず、友達に話しかけるように答えてください。

      回答のルール：
      - 質問に直接関係する情報だけ答えること
      - 聞かれていないことは絶対に追加しないこと
      - 「【参考1】」などの参考番号は回答に含めないこと
      - 簡潔に2〜3文以内でまとめること
      - 参考情報に含まれていない内容は「それはちょっとわからないな〜」と一言で伝えること
      - 回答は必ず#{reptile_name}についてのみ答えること。参考情報に他の種の記載があっても、それらには言及しないこと
    PROMPT
  end
end
