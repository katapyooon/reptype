namespace :ingestion do
  desc "指定した爬虫類のドキュメントを ingestion する（例: rails ingestion:run TYPE_ID=1）"
  task run: :environment do
    type_id = ENV.fetch("TYPE_ID").to_i
    Rails.logger.info "[Ingestion] type_id=#{type_id} 開始"
    DocumentIngestionService.new(reptile_type_id: type_id).run
  end

  desc "全爬虫類のドキュメントを ingestion する"
  task run_all: :environment do
    type_ids = Type.pluck(:id)
    Rails.logger.info "[Ingestion] 全 #{type_ids.size} 件を処理します"
    type_ids.each do |type_id|
      DocumentIngestionService.new(reptile_type_id: type_id).run
    end
  end
end
