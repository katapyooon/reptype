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
    answers = Answer.where(question_id: Question.pluck(:id))

    calculator = Calculator.new(answers)
    code = calculator.result_code

    result = Result.find_by(code: code)

    redirect_to result_path(result)
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
