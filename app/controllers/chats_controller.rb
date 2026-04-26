class ChatsController < ApplicationController
  before_action :check_feature_enabled!
  before_action :set_result
  before_action :authorize_result!

  def show
  end

  def create
    question = params[:question].to_s.strip

    if question.blank?
      render json: { answer: "なにか質問してみてよ！" }
      return
    end

    if question.length > 400
      render json: { answer: "質問は400文字以内にしてね！" }
      return
    end

    chunks = RagSearchService.new(reptile_type_id: @result.type_id).search(question)

    answer = if chunks.empty?
      "うーん、それはちょっとわからないな〜"
    else
      BedrockChatService.new.call(question: question, chunks: chunks, reptile_name: @result.type.name)
    end

    render json: { answer: answer }
  end

  private

  def check_feature_enabled!
    unless FEATURES[:chat_enabled]
      redirect_to root_path, alert: "現在この機能はご利用いただけません。"
    end
  end

  def set_result
    @result = Result.find(params[:result_id])
  end

  def authorize_result!
    authorized_ids = session[:authorized_result_ids] || []
    unless authorized_ids.include?(@result.id)
      if action_name == "show"
        redirect_to result_path(@result), alert: "セッションが切れました。もう一度診断してください。"
      else
        render json: { answer: "セッションが切れました。もう一度診断してください。" }
      end
    end
  end
end
