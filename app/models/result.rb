class Result < ApplicationRecord
  belongs_to :type

  validates :code, presence: true
end
