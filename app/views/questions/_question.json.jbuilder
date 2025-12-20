json.extract! question, :id, :category, :content, :position, :created_at, :updated_at
json.url question_url(question, format: :json)
