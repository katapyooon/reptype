require "test_helper"

class ResultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @result = results(:one)
  end

  test "show returns 404 when the result is not authorized" do
    get result_url(@result)
    assert_response :not_found
  end

  test "pdf_preview returns 404 when the result is not authorized" do
    get pdf_preview_result_url(@result)
    assert_response :not_found
  end

  test "export_pdf returns 404 when the result is not authorized" do
    get export_pdf_result_url(@result)
    assert_response :not_found
  end

  test "create redirects to questions when answers are missing" do
    post results_url
    assert_redirected_to questions_url
  end

  test "does not expose index, edit, update or destroy" do
    assert_no_route :get, "/results"
    assert_no_route :get, "/results/#{@result.id}/edit"
    assert_no_route :patch, "/results/#{@result.id}"
    assert_no_route :delete, "/results/#{@result.id}"
  end
end
