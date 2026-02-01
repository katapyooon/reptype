class ResultsController < ApplicationController
  before_action :set_result, only: %i[ show edit update destroy ]

  # GET /results or /results.json
  def index
    @results = Result.all
  end

  # GET /results/1 or /results/1.json
  def show
    @result = Result.find(params[:id])
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

    Rails.logger.info "[ResultsController#create] Answers: #{answers_data.inspect}"
    Rails.logger.info "[ResultsController#create] Calculator code: #{code.inspect}"

    result = Result.find_by(code: code)

    if result.present?
      Rails.logger.info "[ResultsController#create] Found result id=#{result.id} code=#{result.code.inspect}"
      redirect_to result_path(result)
    else
      Rails.logger.warn "[ResultsController#create] No Result found for code=#{code.inspect}. Available codes: #{Result.pluck(:code).uniq.inspect}"
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

    # Only allow a list of trusted parameters through.
    def result_params
      params.expect(result: [ :code, :type_id, :summary, :explanation ])
    end
end
