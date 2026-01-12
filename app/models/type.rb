class Type < ApplicationRecord
    has_many :results, dependent: :destroy

    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
end
