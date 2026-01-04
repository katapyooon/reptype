class Question < ApplicationRecord
    has_many :answers, dependent: :destroy  # 追加: 質問削除時に回答も削除

    ## categoryのバリデーションを追加
    validates :category, presence: true, inclusion: { in: ['A', 'B', 'C', 'D'] }
end
