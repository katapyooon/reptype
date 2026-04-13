class RagSearchService
  # pgvector のコサイン類似度検索で関連チャンクを取得する
  DEFAULT_LIMIT = 5

  def initialize(reptile_type_id:)
    @reptile_type_id = reptile_type_id
    @embedding_service = BedrockEmbeddingService.new
  end

  # query に関連するチャンクを返す
  # @return [Array<DocumentChunk>]
  def search(query, limit: DEFAULT_LIMIT)
    query_embedding = @embedding_service.embed(query)

    DocumentChunk
      .where(reptile_type_id: @reptile_type_id)
      .nearest_neighbors(:embedding, query_embedding, distance: "cosine")
      .limit(limit)
  end
end
