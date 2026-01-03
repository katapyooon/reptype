require "test_helper"

class LikertControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get likert_url
    assert_response :success
  end
end
