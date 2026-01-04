class HomeController < ApplicationController
  def index
    @question = Question.all
  end

  def answer_questions
    # 質問に回答するためのロジックをここに追加できます
    redirect_to questions_path
  end
end
