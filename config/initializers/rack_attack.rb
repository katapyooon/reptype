class Rack::Attack
  # Solid Cache（既存インフラ）をバックエンドとして使用
  Rack::Attack.cache.store = Rails.cache

  # 全リクエスト: IP単位で1分間60回まで
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # チャットAPI: IP単位で1分間5回まで（Bedrock課金防止）
  throttle("chat/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path.include?("/chat")
  end

  # 短時間に集中した攻撃をブロック（10秒間に30超でban、5分間）
  blocklist("chat/ip/burst") do |req|
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 30, findtime: 10.seconds, bantime: 5.minutes) do
      req.path.include?("/chat")
    end
  end

  throttled_responder = lambda do |req|
    [ 429, { "Content-Type" => "application/json" }, [ { error: "Too many requests. Please try again later." }.to_json ] ]
  end
  self.throttled_responder = throttled_responder
end
