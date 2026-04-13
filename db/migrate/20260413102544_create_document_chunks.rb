class CreateDocumentChunks < ActiveRecord::Migration[8.0]
  def change
    create_table :document_chunks do |t|
      t.integer  :reptile_type_id, null: false   # types テーブルの id に対応
      t.string   :source_file,     null: false   # S3 のファイルパス（例: reptile/1/overview.md）
      t.text     :content,         null: false   # チャンクのテキスト内容
      t.vector   :embedding,       limit: 1024   # Titan Embed V2 の次元数

      t.timestamps
    end

    add_index :document_chunks, :reptile_type_id
    add_index :document_chunks, :embedding, using: :hnsw,
              opclass: :vector_cosine_ops
  end
end
