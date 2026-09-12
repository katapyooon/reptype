class MorphsController < ApplicationController
  # GET /morphs
  def index
    @morphs = CatalogApiClient.list_morphs
  rescue CatalogApiClient::Error => e
    @morphs = []
    @error = e.message
  end

  # GET /morphs/:code
  def show
    @morph = CatalogApiClient.find_morph(params[:code])
    redirect_to morphs_path, alert: "モルフが見つかりませんでした" and return if @morph.nil?
  rescue CatalogApiClient::Error
    redirect_to morphs_path, alert: "図鑑APIに接続できませんでした"
  end
end
