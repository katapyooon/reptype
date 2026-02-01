class Answer < ApplicationRecord
  belongs_to :question

  validates :score,
    inclusion: { in: 1..5 }, presence: true
end
