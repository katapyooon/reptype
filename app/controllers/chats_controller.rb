class ChatsController < ApplicationController
  before_action :set_result
  before_action :authorize_result!

  def show
  end

  def create
    @question = params[:question].to_s.strip

    if @question.blank?
      @answer = "なにか質問してみてよ！"
      respond_to_formats and return
    end

    chunks = RagSearchService.new(reptile_type_id: @result.type_id).search(@question)

    @answer = if chunks.empty?
      "うーん、それはちょっとわからないな〜"
    else
      BedrockChatService.new.call(question: @question, chunks: chunks)
    end

    respond_to_formats
  end

  private

  def set_result
    @result = Result.find(params[:result_id])
  end

  def authorize_result!
    authorized_ids = session[:authorized_result_ids] || []
    unless authorized_ids.include?(@result.id)
      if action_name == "show"
        redirect_to result_path(@result), alert: "セッションが切れました。もう一度診断してください。"
      else
        @question = ""
        @answer = "セッションが切れました。もう一度診断してください。"
        respond_to_formats
      end
    end
  end

  def respond_to_formats
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to result_chat_path(@result) }
    end
  end
end
