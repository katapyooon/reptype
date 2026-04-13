class EnableVectorExtension < ActiveRecord::Migration[8.0]
  # Amazon RDS では rds_superuser 権限が必要なため、
  # 本番環境では事前にマスターユーザーで以下を実行しておくこと:
  #   CREATE EXTENSION IF NOT EXISTS vector;
  def up
    enable_extension "vector" unless extension_enabled?("vector")
  end

  def down
    disable_extension "vector"
  end
end
