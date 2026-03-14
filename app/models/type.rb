class Type < ApplicationRecord
    has_many :results, dependent: :destroy

    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    validates :image_path, allow_blank: true, format: {
      with: /\A[\w.\/-]+\z/,
      message: "only allows alphanumeric characters, dots, forward slashes, underscores, and hyphens"
    }
end
