class ResultsController < ApplicationController
  before_action :set_result, only: %i[ show export_pdf pdf_preview ]
  before_action :authorize_result!, only: %i[ show export_pdf pdf_preview ]

  # GET /results/1
  def show
    # @result は set_result で設定済み（二重findを削除）
  end

  # POST /results
  def create
    # バリデーション: 全問回答したかチェック
    question_count = Question.count
    answers_data = params[:answers] || {}

    if answers_data.empty? || answers_data.keys.length != question_count
      redirect_to questions_path, alert: "すべての質問に回答してください。"
      return
    end

    # 質問IDを確認
    question_ids = Question.pluck(:id).map(&:to_s).sort
    provided_ids = answers_data.keys.sort

    unless question_ids == provided_ids
      redirect_to questions_path, alert: "無効な質問データです。"
      return
    end

    # フォームから送られた回答データをそのまま Calculator に渡す
    calculator = Calculator.new(answers_data)
    code = calculator.result_code

    Rails.logger.debug "[ResultsController#create] Answers: #{answers_data.inspect}"
    Rails.logger.debug "[ResultsController#create] Calculator code: #{code.inspect}"

    result = Result.find_by(code: code)

    if result.present?
      Rails.logger.debug "[ResultsController#create] Found result id=#{result.id} code=#{result.code.inspect}"
      # ③: セッション固定化攻撃を防ぐため、結果確定時に新しいセッションIDを生成する
      reset_session
      session[:authorized_result_ids] = [ result.id ]
      redirect_to result_path(result)
    else
      Rails.logger.warn "[ResultsController#create] No Result found for code=#{code.inspect}"
      redirect_to questions_path, alert: "結果が見つかりませんでした。管理者にお問い合わせください。"
    end
  end

  # GET /results/:id/pdf_preview
  def pdf_preview
    service   = PdfExportService.new(@result)
    @sections = service.generate_sections
    @type     = @result.type
  end

  # GET /results/:id/export_pdf
  def export_pdf
    pdf = PdfExportService.new(@result).generate_pdf
    send_data pdf,
      filename:    "#{@result.type.name}_care_sheet.pdf",
      type:        "application/pdf",
      disposition: "attachment"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_result
      @result = Result.find(params.expect(:id))
    end

    # ④: セッションに保存された認可済みresult_idと照合する
    def authorize_result!
      authorized_ids = session[:authorized_result_ids] || []
      unless authorized_ids.include?(@result.id)
        redirect_to root_path, alert: "アクセス権限がありません。診断を完了してから結果を確認してください。"
      end
    end
end
