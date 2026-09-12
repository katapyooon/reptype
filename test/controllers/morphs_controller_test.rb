require "test_helper"

class MorphsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    morphs = [ { "code" => "enigma", "name" => "Enigma", "description" => "desc" } ]

    stub_class_method(CatalogApiClient, :list_morphs, morphs) do
      get morphs_url
    end

    assert_response :success
  end

  test "index shows an error message when the catalog API is unreachable" do
    stub_class_method(CatalogApiClient, :list_morphs, ->() { raise CatalogApiClient::Error, "boom" }) do
      get morphs_url
    end

    assert_response :success
  end

  test "should get show" do
    morph = { "code" => "enigma", "name" => "Enigma", "description" => "desc", "genes" => [], "combination_risks" => [] }

    stub_class_method(CatalogApiClient, :find_morph, morph) do
      get morph_url("enigma")
    end

    assert_response :success
  end

  test "show redirects to index when morph is not found" do
    stub_class_method(CatalogApiClient, :find_morph, nil) do
      get morph_url("does_not_exist")
    end

    assert_redirected_to morphs_url
  end

  test "show redirects to index when the catalog API is unreachable" do
    stub_class_method(CatalogApiClient, :find_morph, ->(_code) { raise CatalogApiClient::Error, "boom" }) do
      get morph_url("enigma")
    end

    assert_redirected_to morphs_url
  end
end
