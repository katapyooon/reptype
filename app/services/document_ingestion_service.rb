class DocumentIngestionService
  # S3 の reptile/:type_id/ 以下の .md ファイルを読み込み、
  # チャンク化して埋め込みを生成し document_chunks に保存する
  CHUNK_SIZE = 500  # 文字数（日本語で意味的なまとまりを保てるサイズ）

  def initialize(reptile_type_id:)
    @reptile_type_id = reptile_type_id
    @bucket_name = ENV.fetch("DOCUMENTS_BUCKET_NAME")
    @s3 = Aws::S3::Client.new(region: ENV.fetch("AWS_REGION", "ap-northeast-1"))
    @embedding_service = BedrockEmbeddingService.new
  end

  def run
    keys = list_document_keys
    if keys.empty?
      Rails.logger.info "[Ingestion] type_id=#{@reptile_type_id}: ドキュメントが見つかりません"
      return
    end

    DocumentChunk.where(reptile_type_id: @reptile_type_id).delete_all
    Rails.logger.info "[Ingestion] type_id=#{@reptile_type_id}: #{keys.size} ファイルを処理します"

    keys.each { |key| ingest_file(key) }

    Rails.logger.info "[Ingestion] type_id=#{@reptile_type_id}: 完了"
  end

  private

  def list_document_keys
    prefix = "reptile/#{@reptile_type_id}/"
    response = @s3.list_objects_v2(bucket: @bucket_name, prefix: prefix)
    response.contents
      .map(&:key)
      .select { |key| key.end_with?(".md") }
  end

  def ingest_file(key)
    body = @s3.get_object(bucket: @bucket_name, key: key).body.read.force_encoding("UTF-8")
    chunks = split_into_chunks(body)
    Rails.logger.info "[Ingestion]   #{key}: #{chunks.size} チャンク"

    chunks.each do |chunk|
      next if chunk.strip.empty?

      embedding = @embedding_service.embed(chunk)
      DocumentChunk.create!(
        reptile_type_id: @reptile_type_id,
        source_file: key,
        content: chunk,
        embedding: embedding
      )
    end
  end

  # Markdown の ## 見出しを区切りとしてチャンク分割する。
  # 見出し単位で分割したブロックが CHUNK_SIZE を超える場合はさらに段落単位で分割する。
  def split_into_chunks(text)
    # ## 以上の見出しで分割
    sections = text.split(/(?=^##+ )/)
    chunks = []

    sections.each do |section|
      if section.length <= CHUNK_SIZE
        chunks << section.strip
      else
        # 段落（空行）単位でさらに分割
        paragraphs = section.split(/\n{2,}/)
        buffer = ""
        paragraphs.each do |para|
          if (buffer + para).length > CHUNK_SIZE && buffer.present?
            chunks << buffer.strip
            buffer = para
          else
            buffer = buffer.empty? ? para : "#{buffer}\n\n#{para}"
          end
        end
        chunks << buffer.strip if buffer.present?
      end
    end

    chunks.reject(&:empty?)
  end
end
