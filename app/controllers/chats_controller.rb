class ChatsController < ApplicationController
  before_action :set_result
  before_action :authorize_result!

  def create
    question = params[:question].to_s.strip

    if question.blank?
      @answer = "質問を入力してください。"
      render "chats/create" and return
    end

    chunks = RagSearchService.new(reptile_type_id: @result.type_id).search(question)

    @answer = if chunks.empty?
      "申し訳ありません。関連する情報が見つかりませんでした。"
    else
      BedrockChatService.new.call(question: question, chunks: chunks)
    end

    render "chats/create"
  end

  private

  def set_result
    @result = Result.find(params[:result_id])
  end

  def authorize_result!
    authorized_ids = session[:authorized_result_ids] || []
    unless authorized_ids.include?(@result.id)
      @answer = "セッションが切れました。もう一度診断してください。"
      render "chats/create"
    end
  end
end
