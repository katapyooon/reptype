class QuestionsController < ApplicationController
  # GET /questions
  def index
    @questions = Question.all
  end

  def answer
    # 質問に回答するためのロジックをここに追加できます
    redirect_to questions_path
  end
end
