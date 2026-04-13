class DocumentChunk < ApplicationRecord
  has_neighbors :embedding
end
