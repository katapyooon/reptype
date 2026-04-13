# AWS SDK グローバル設定
# リージョンや SSL 設定など環境ごとの差異をここで一元管理する。
# 各サービスクラスでは Aws::*.Client.new のみで使用できる。

Aws.config.update(
  region: ENV.fetch("AWS_REGION", "ap-northeast-1")
)

# 開発環境: ローカルの証明書 CRL 検証エラーを回避するため SSL 検証をスキップ
# 本番環境: デフォルトの true のまま（変更しない）
Aws.config.update(ssl_verify_peer: false) if Rails.env.development?
