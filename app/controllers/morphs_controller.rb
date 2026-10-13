class MorphsController < ApplicationController
  include ResultAuthorization

  before_action :ensure_catalog_enabled!
  before_action :set_result
  before_action :authorize_result!

  # 診断結果のType名 => 図鑑API(reptype-catalog-api)側のspeciesコード
  # 図鑑データが用意されている種のみここに追加していく
  SPECIES_CODE_BY_TYPE_NAME = {
    "ヒョウモントカゲモドキ" => "leopard_gecko"
  }.freeze

  # GET /results/:result_id/morphs
  def index
    @species_code = species_code
    @morphs = @species_code ? CatalogApiClient.list_morphs(species: @species_code) : []
  rescue CatalogApiClient::Error => e
    @morphs = []
    @error = e.message
  end

  # GET /results/:result_id/morphs/:code
  def show
    @morph = species_code && CatalogApiClient.find_morph(params[:code], species: species_code)
    redirect_to result_morphs_path(@result), alert: "モルフが見つかりませんでした" and return if @morph.nil?
  rescue CatalogApiClient::Error
    redirect_to result_morphs_path(@result), alert: "図鑑APIに接続できませんでした"
  end

  private

  # 本番ではローカル検証が終わるまで機能自体を非表示にするためのfeature flag。
  # URL直打ちでのアクセスも防ぐ(表示側は results/show.html.erb 側で制御)。
  # 無効時は機能が存在しないものとして 404 を返す。
  def ensure_catalog_enabled!
    raise ActionController::RoutingError, "Not Found" unless helpers.morphs_catalog_enabled?
  end

  def set_result
    @result = Result.find(params[:result_id])
  end

  def species_code
    SPECIES_CODE_BY_TYPE_NAME[@result.type.name]
  end
end
