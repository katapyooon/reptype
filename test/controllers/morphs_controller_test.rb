require "test_helper"

class MorphsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @leopard_type = Type.create!(name: "ヒョウモントカゲモドキ", code: "LEOPARD_TEST")
    @leopard_result = Result.create!(code: "LEOPARD_TEST", type: @leopard_type)

    @other_type = Type.create!(name: "フトアゴヒゲトカゲ", code: "OTHER_TEST")
    @other_result = Result.create!(code: "OTHER_TEST", type: @other_type)
  end

  test "index returns 404 when the result is not authorized" do
    get result_morphs_url(@leopard_result)
    assert_response :not_found
  end

  test "index returns 404 when the catalog feature flag is disabled" do
    with_catalog_disabled do
      as_authorized(@leopard_result) do
        get result_morphs_url(@leopard_result)
      end
    end

    assert_response :not_found
  end

  test "show returns 404 when the catalog feature flag is disabled" do
    with_catalog_disabled do
      as_authorized(@leopard_result) do
        get result_morph_url(@leopard_result, "enigma")
      end
    end

    assert_response :not_found
  end

  test "should get index for a species with catalog data" do
    morphs = [ { "code" => "enigma", "name" => "Enigma", "description" => "desc" } ]

    as_authorized(@leopard_result) do
      stub_class_method(CatalogApiClient, :list_morphs, morphs) do
        get result_morphs_url(@leopard_result)
      end
    end

    assert_response :success
  end

  test "index shows a coming-soon message for a species without catalog data" do
    as_authorized(@other_result) do
      get result_morphs_url(@other_result)
    end

    assert_response :success
    assert_select "p", text: "この爬虫類のモルフ図鑑は準備中です。"
  end

  test "index shows an error message when the catalog API is unreachable" do
    as_authorized(@leopard_result) do
      stub_class_method(CatalogApiClient, :list_morphs, ->(*) { raise CatalogApiClient::Error, "boom" }) do
        get result_morphs_url(@leopard_result)
      end
    end

    assert_response :success
  end

  test "should get show" do
    morph = { "code" => "enigma", "name" => "Enigma", "description" => "desc" }

    as_authorized(@leopard_result) do
      stub_class_method(CatalogApiClient, :find_morph, morph) do
        get result_morph_url(@leopard_result, "enigma")
      end
    end

    assert_response :success
  end

  test "show redirects to index when the species has no catalog data" do
    as_authorized(@other_result) do
      get result_morph_url(@other_result, "enigma")
    end

    assert_redirected_to result_morphs_url(@other_result)
  end

  test "show redirects to index when morph is not found" do
    as_authorized(@leopard_result) do
      stub_class_method(CatalogApiClient, :find_morph, nil) do
        get result_morph_url(@leopard_result, "does_not_exist")
      end
    end

    assert_redirected_to result_morphs_url(@leopard_result)
  end

  test "show redirects to index when the catalog API is unreachable" do
    as_authorized(@leopard_result) do
      stub_class_method(CatalogApiClient, :find_morph, ->(*) { raise CatalogApiClient::Error, "boom" }) do
        get result_morph_url(@leopard_result, "enigma")
      end
    end

    assert_redirected_to result_morphs_url(@leopard_result)
  end

  private

  # MorphsController#authorize_result! gates access on session[:authorized_result_ids],
  # but the session cookie isn't established until a real request writes to it, so
  # mutating `session` directly between requests in an integration test doesn't
  # persist. Bypass the check itself for tests that aren't exercising authorization.
  def as_authorized(_result, &block)
    stub_instance_method(MorphsController, :authorize_result!, -> { }, &block)
  end

  def with_catalog_disabled
    original = Rails.application.config.x.morphs_catalog_enabled
    Rails.application.config.x.morphs_catalog_enabled = false
    yield
  ensure
    Rails.application.config.x.morphs_catalog_enabled = original
  end
end
