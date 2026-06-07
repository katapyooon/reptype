class PdfExportService
  BEDROCK_MODEL_ID = "jp.anthropic.claude-haiku-4-5-20251001-v1:0"
  DESCRIPTION_QUERY = "基本的な特徴・性格・飼育のポイントを教えてください"

  def initialize(result)
    @result = result
    @type = result.type
  end

  def generate_pdf
    description = generate_description
    image_uri   = build_image_data_uri
    html        = render_html(description: description, image_uri: image_uri)
    Grover.new(html, **Grover.configuration.options).to_pdf
  end

  private

  def generate_description
    chunks = RagSearchService.new(reptile_type_id: @type.id)
                             .search(DESCRIPTION_QUERY, limit: 5)
    return @type.description if chunks.empty?

    call_bedrock_for_description(chunks)
  end

  def call_bedrock_for_description(chunks)
    client  = Aws::BedrockRuntime::Client.new
    context = chunks.map.with_index(1) { |c, i| "【参考#{i}】\n#{c.content}" }.join("\n\n")

    response = client.invoke_model(
      model_id:     BEDROCK_MODEL_ID,
      content_type: "application/json",
      accept:       "application/json",
      body: {
        anthropic_version: "bedrock-2023-05-31",
        max_tokens: 600,
        system: pdf_system_prompt,
        messages: [
          {
            role:    "user",
            content: "以下の参考情報をもとに#{@type.name}の基本情報を400字程度でまとめてください。\n\n#{context}"
          }
        ]
      }.to_json
    )

    body = JSON.parse(response.body.read)
    body.dig("content", 0, "text") || @type.description
  end

  def pdf_system_prompt
    <<~PROMPT
      あなたは爬虫類飼育の専門家です。
      提供された参考情報をもとに、#{@type.name}の基本情報を400字程度の自然な日本語で説明してください。
      特徴・性格・飼育のポイントを含め、初心者にも分かりやすく書いてください。
      箇条書きは使わず、読み物として自然な文章で書いてください。
    PROMPT
  end

  def build_image_data_uri
    return nil unless @type.image_path.present?

    file_path = Rails.root.join("app/assets/images", @type.image_path)
    return nil unless File.exist?(file_path)

    data      = Base64.strict_encode64(File.binread(file_path))
    ext       = File.extname(@type.image_path).delete(".").downcase
    mime_type = ext == "jpg" ? "jpeg" : ext
    "data:image/#{mime_type};base64,#{data}"
  end

  def render_html(description:, image_uri:)
    ApplicationController.render(
      template: "results/export_pdf",
      assigns:  { type: @type, description: description, image_uri: image_uri },
      layout:   false
    )
  end
end
