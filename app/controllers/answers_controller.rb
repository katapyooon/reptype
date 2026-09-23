class AnswersController < ApplicationController
  # POST /answers.json
  # likert_controller.js から1問回答するごとに呼ばれる
  def create
    answer = Answer.new(answer_params)

    if answer.save
      head :created
    else
      render json: answer.errors, status: :unprocessable_entity
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def answer_params
      params.expect(answer: [ :question_id, :score ])
    end
end
