require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "shows service close notice" do
    get root_url
    assert_select ".service-close-notice", text: /2026年11月9日/
  end

  test "does not expose type management" do
    assert_no_route :get, "/types"
    assert_no_route :post, "/types"
    assert_no_route :patch, "/types/1"
    assert_no_route :delete, "/types/1"
  end
end
