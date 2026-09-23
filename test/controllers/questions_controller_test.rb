require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @question = questions(:one)
  end

  test "should get index" do
    get questions_url
    assert_response :success
  end

  test "answer redirects to index" do
    post answer_question_url(@question)
    assert_redirected_to questions_url
  end

  test "does not expose CRUD actions other than index" do
    assert_no_route :get, "/questions/new"
    assert_no_route :get, "/questions/#{@question.id}"
    assert_no_route :get, "/questions/#{@question.id}/edit"
    assert_no_route :post, "/questions"
    assert_no_route :patch, "/questions/#{@question.id}"
    assert_no_route :delete, "/questions/#{@question.id}"
  end
end
