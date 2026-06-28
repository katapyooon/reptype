class PdfExportService
  BEDROCK_MODEL_ID = "jp.anthropic.claude-haiku-4-5-20251001-v1:0"

  DESCRIPTION_QUERY = "基本的な特徴・性格・飼育のポイントを教えてください"
  CAGE_SIZE_QUERY   = "推奨されるケージのサイズを教えてください"
  EQUIPMENT_QUERY   = "必要な暖房器具・シェルター・床材を教えてください"
  FEEDING_QUERY     = "餌の種類と給餌頻度を教えてください"

  # 除外する不要行のパターン
  NOISE_PATTERNS = [
    /参考\d+/,
    /正確な回答をするため/,
    /適切な参考情報/,
    /情報の提供をお願い/
  ].freeze

  def initialize(result)
    @result = result
    @type   = result.type
    @client = Aws::BedrockRuntime::Client.new
  end

  def generate_pdf
    description = format_for_pdf(generate_description)
    cage_size   = format_for_pdf(generate_section(CAGE_SIZE_QUERY, cage_size_prompt))
    equipment   = format_for_pdf(generate_section(EQUIPMENT_QUERY, equipment_prompt))
    feeding     = format_for_pdf(generate_section(FEEDING_QUERY,   feeding_prompt))
    image_uri   = build_image_data_uri

    html = render_html(
      description: description,
      cage_size:   cage_size,
      equipment:   equipment,
      feeding:     feeding,
      image_uri:   image_uri
    )
    Grover.new(html, **Grover.configuration.options).to_pdf
  end

  private

  # マークダウンをHTMLに変換し不要行を除去する
  # HTMLエスケープを先に行い、その後マークダウン記法のみを安全なタグに変換する
  def format_for_pdf(text)
    return nil if text.blank?

    lines = text.lines.reject { |line| NOISE_PATTERNS.any? { |pat| line.match?(pat) } }

    lines.map do |line|
      escaped = ERB::Util.html_escape(line)
      # # 見出し → <strong>テキスト</strong>（エスケープ済みテキストに適用）
      escaped = escaped.gsub(/^#+\s*(.+)$/) { "<strong>#{$1.strip}</strong>" }
      # **bold** → <strong>bold</strong>（エスケープ済みテキストに適用）
      escaped = escaped.gsub(/\*\*(.+?)\*\*/) { "<strong>#{$1}</strong>" }
      escaped
    end.join
  end

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
      冒頭に「#{@type.name}の基本情報」という見出しを **#{@type.name}の基本情報** の形式で必ず入れてください。
      「参考1」「参考2」などの参考番号は回答に含めないこと。
      情報が不足している場合の断り書きも不要です。
    PROMPT
  end

  def cage_size_prompt
    <<~PROMPT
      あなたは爬虫類飼育の専門家です。
      提供された参考情報をもとに、#{@type.name}に必要なケージのサイズを簡潔に答えてください。
      最低サイズと推奨サイズを分けて、具体的な数値で記載してください。
      箇条書きで2項目（最低サイズ・推奨サイズのみ）にまとめてください。
      各項目は「• **最低サイズ**：幅〇〇cm×奥行〇〇cm×高さ〇〇cm」「• **推奨サイズ**：幅〇〇cm×奥行〇〇cm×高さ〇〇cm」の形式で必ず記載してください。
      幅・奥行・高さの3つの数値をすべて含めること。
      タイトルや見出し行は含めないでください。
      「より理想的」「さらに広い」などの追加項目は含めないでください。
      「参考1」「参考2」などの参考番号は回答に含めないこと。
      情報が不足している場合の断り書きも不要です。
    PROMPT
  end

  def equipment_prompt
    <<~PROMPT
      あなたは爬虫類飼育の専門家です。
      提供された参考情報をもとに、#{@type.name}の飼育に必要な暖房器具・シェルター・床材を答えてください。
      カテゴリごとに箇条書きで簡潔にまとめてください。
      各カテゴリは「**暖房器具**：」「**シェルター**：」「**床材**：」の形式で記載してください。
      タイトルや見出し行は含めないでください。
      「参考1」「参考2」などの参考番号は回答に含めないこと。
      情報が不足している場合の断り書きも不要です。
    PROMPT
  end

  ALLOWED_IMAGE_EXTENSIONS = %w[jpg jpeg png gif webp].freeze

  def build_image_data_uri
    return nil unless @type.image_path.present?

    # パス区切り文字を含まないファイル名のみ許可し、許可拡張子かチェック
    basename = File.basename(@type.image_path)
    ext      = File.extname(basename).delete(".").downcase
    return nil unless basename.match?(/\A[\w\-]+\.\w+\z/) && ALLOWED_IMAGE_EXTENSIONS.include?(ext)

    images_dir = Rails.root.join("app/assets/images")
    file_path  = images_dir.join(basename)

    # realpath でシンボリックリンク等を解決し、images_dir 配下であることを保証
    return nil unless File.exist?(file_path)
    return nil unless file_path.realpath.to_s.start_with?(images_dir.realpath.to_s + "/")

    data      = Base64.strict_encode64(File.binread(file_path))
    mime_type = ext == "jpg" ? "jpeg" : ext
    "data:image/#{mime_type};base64,#{data}"
  end

  def feeding_prompt
    <<~PROMPT
      あなたは爬虫類飼育の専門家です。
      提供された参考情報をもとに、#{@type.name}の餌の種類と給餌頻度を簡潔に答えてください。
      以下の形式で記載してください：
      • **主食**：〇〇、〇〇
      • **副食**：〇〇、〇〇（ある場合のみ）
      • **幼体**：〇〇に1回
      • **成体**：〇〇に1回
      タイトルや見出し行は含めないでください。
      「参考1」「参考2」などの参考番号は回答に含めないこと。
      情報が不足している場合の断り書きも不要です。
    PROMPT
  end

  def render_html(description:, cage_size:, equipment:, feeding:, image_uri:)
    ApplicationController.render(
      template: "results/export_pdf",
      assigns:  {
        type:        @type,
        description: description,
        cage_size:   cage_size,
        equipment:   equipment,
        feeding:     feeding,
        image_uri:   image_uri
      },
      layout: false
    )
  end
end
