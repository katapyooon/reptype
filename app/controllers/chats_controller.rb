class ChatsController < ApplicationController
  include ResultAuthorization

  QUESTION_MAX_LENGTH = 400

  # Bedrock(埋め込み・回答生成)を呼べなかったときの例外
  UPSTREAM_ERRORS = [
    Aws::Errors::ServiceError,
    Aws::Errors::MissingCredentialsError,
    Seahorse::Client::NetworkingError
  ].freeze

  rescue_from ActiveRecord::RecordNotFound, with: :result_not_found

  before_action :set_result
  before_action :authorize_result!

  def show
  end

  # POST /results/:result_id/chat
  # 成功時は 200 { answer: "..." }、失敗時は 4xx/5xx { error: { code:, message: } } を返す
  def create
    question = params[:question].to_s.strip

    if question.blank?
      render_error :unprocessable_entity, "なにか質問してみてよ！"
      return
    end

    if question.length > QUESTION_MAX_LENGTH
      render_error :unprocessable_entity, "質問は#{QUESTION_MAX_LENGTH}文字以内にしてね！"
      return
    end

    chunks = RagSearchService.new(reptile_type_id: @result.type_id).search(question)

    # 参考情報が見つからないのはエラーではなく「わからない」という正常な回答
    answer = if chunks.empty?
      "うーん、それはちょっとわからないな〜"
    else
      BedrockChatService.new.call(question: question, chunks: chunks, reptile_name: @result.type.name)
    end

    render json: { answer: answer }
  rescue *UPSTREAM_ERRORS => e
    Rails.logger.error("[ChatsController#create] #{e.class}: #{e.message}")
    render_error :service_unavailable, "いまは答えられないみたい。少し待ってからまた聞いてね！"
  end

  private

  def set_result
    @result = Result.find(params[:result_id])
  end

  # 結果が存在しない・未認可のどちらも 404(ResultAuthorization 参照)。
  # show(HTML)は通常どおり 404 ページ、create(JSON)は JSON で 404 を返す
  def result_not_found(exception)
    raise exception if action_name == "show"

    render_error :not_found, "診断結果が見つかりませんでした。もう一度診断してください。"
  end

  def render_error(status, message)
    render json: { error: { code: status.to_s, message: message } }, status: status
  end
end
