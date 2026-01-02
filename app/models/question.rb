class Question < ApplicationRecord
    has_many :answers, dependent: :destroy  # 追加: 質問削除時に回答も削除
end
