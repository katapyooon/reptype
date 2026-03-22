class HomeController < ApplicationController
  def index
    @question = Question.first
  end

  def answer_questions
    # 質問に回答するためのロジックをここに追加できます
    redirect_to questions_path
  end
end
