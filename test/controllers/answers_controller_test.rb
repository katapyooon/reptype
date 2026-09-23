require "test_helper"

class AnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @answer = answers(:one)
  end

  test "should create answer" do
    assert_difference("Answer.count") do
      post answers_url, params: { answer: { question_id: @answer.question_id, score: @answer.score } }, as: :json
    end

    assert_response :created
  end

  test "should not create answer with invalid score" do
    assert_no_difference("Answer.count") do
      post answers_url, params: { answer: { question_id: @answer.question_id, score: 99 } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "does not expose index, show, update or destroy" do
    assert_no_route :get, "/answers"
    assert_no_route :get, "/answers/#{@answer.id}"
    assert_no_route :patch, "/answers/#{@answer.id}"
    assert_no_route :delete, "/answers/#{@answer.id}"
  end
end
