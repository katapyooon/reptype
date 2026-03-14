class ResultsController < ApplicationController
  before_action :set_result, only: %i[ show edit update destroy ]
  before_action :authorize_result!, only: :show  # ④: showに認可チェックを追加

  # GET /results or /results.json
  def index
    @results = Result.all
  end

  # GET /results/1 or /results/1.json
  def show
    # @result は set_result で設定済み（二重findを削除）
  end

  # GET /results/new
  def new
    @result = Result.new
  end

  # GET /results/1/edit
  def edit
  end

  # POST /results or /results.json
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
      redirect_to results_path, alert: "結果が見つかりませんでした。管理者にお問い合わせください。"
    end
  end

  # PATCH/PUT /results/1 or /results/1.json
  def update
    respond_to do |format|
      if @result.update(result_params)
        format.html { redirect_to @result, notice: "Result was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @result }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1 or /results/1.json
  def destroy
    @result.destroy!

    respond_to do |format|
      format.html { redirect_to results_path, notice: "Result was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def calculate_result
    answers = Answer.order(created_at: :desc).limit(20)

    calculator = Calculator.new(answers)
    code = calculator.result_code

    result = Result.includes(:type).find_by(code: code)
    redirect_to result_path(result)
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

    # Only allow a list of trusted parameters through.
    def result_params
      params.expect(result: [ :code, :type_id, :summary, :explanation ])
    end
end
