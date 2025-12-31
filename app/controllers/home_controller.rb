class HomeController < ApplicationController
  def index
    @questions = Question.all
  end

  def answer_questions
    # 質問に回答するためのロジックをここに追加できます
    redirect_to questions_path, notice: "質問に回答する画面に移動しました。"
  end
end
