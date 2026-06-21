class PdfExportService
  BEDROCK_MODEL_ID = "jp.anthropic.claude-haiku-4-5-20251001-v1:0"

  DESCRIPTION_QUERY = "基本的な特徴・性格・飼育のポイントを教えてください"
  CAGE_SIZE_QUERY   = "推奨されるケージのサイズを教えてください"
  EQUIPMENT_QUERY   = "必要な暖房器具・シェルター・床材を教えてください"

  def initialize(result)
    @result = result
    @type   = result.type
    @client = Aws::BedrockRuntime::Client.new
  end

  def generate_pdf
    description = generate_description
    cage_size   = generate_section(CAGE_SIZE_QUERY,  cage_size_prompt)
    equipment   = generate_section(EQUIPMENT_QUERY,  equipment_prompt)
    image_uri   = build_image_data_uri

    html = render_html(
      description: description,
      cage_size:   cage_size,
      equipment:   equipment,
      image_uri:   image_uri
    )
    Grover.new(html, **Grover.configuration.options).to_pdf
  end

  private

  def generate_description
    chunks = RagSearchService.new(reptile_type_id: @type.id)
                             .search(DESCRIPTION_QUERY, limit: 5)
    return @type.description if chunks.empty?

    call_bedrock(chunks, description_prompt, "#{@type.name}の基本情報を400字程度でまとめてください。")
  end

  def generate_section(query, system_prompt)
    chunks = RagSearchService.new(reptile_type_id: @type.id)
                             .search(query, limit: 3)
    return nil if chunks.empty?

    call_bedrock(chunks, system_prompt, query)
  end

  def call_bedrock(chunks, system_prompt, user_query)
    context = chunks.map.with_index(1) { |c, i| "【参考#{i}】\n#{c.content}" }.join("\n\n")

    response = @client.invoke_model(
      model_id:     BEDROCK_MODEL_ID,
      content_type: "application/json",
      accept:       "application/json",
      body: {
        anthropic_version: "bedrock-2023-05-31",
        max_tokens: 600,
        system:     system_prompt,
        messages: [
          {
            role:    "user",
            content: "以下の参考情報をもとに答えてください。\n\n#{context}\n\n質問：#{user_query}"
          }
        ]
      }.to_json
    )

    body = JSON.parse(response.body.read)
    body.dig("content", 0, "text")
  end

  def description_prompt
    <<~PROMPT
      あなたは爬虫類飼育の専門家です。
      提供された参考情報をもとに、#{@type.name}の基本情報を400字程度の自然な日本語で説明してください。
      特徴・性格・飼育のポイントを含め、初心者にも分かりやすく書いてください。
      箇条書きは使わず、読み物として自然な文章で書いてください。
    PROMPT
  end

  def cage_size_prompt
    <<~PROMPT
      あなたは爬虫類飼育の専門家です。
      提供された参考情報をもとに、#{@type.name}に必要なケージのサイズを簡潔に答えてください。
      最低サイズと推奨サイズを分けて、具体的な数値（cm）で記載してください。
      箇条書きで2〜3項目程度にまとめてください。
    PROMPT
  end

  def equipment_prompt
    <<~PROMPT
      あなたは爬虫類飼育の専門家です。
      提供された参考情報をもとに、#{@type.name}の飼育に必要な暖房器具・シェルター・床材を答えてください。
      カテゴリごとに箇条書きで簡潔にまとめてください。
      各カテゴリは「暖房器具：」「シェルター：」「床材：」の形式で記載してください。
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

  def render_html(description:, cage_size:, equipment:, image_uri:)
    ApplicationController.render(
      template: "results/export_pdf",
      assigns:  {
        type:        @type,
        description: description,
        cage_size:   cage_size,
        equipment:   equipment,
        image_uri:   image_uri
      },
      layout: false
    )
  end
end
