Rails.application.config.session_store :cookie_store,
  key: "_reptype_session",
  httponly: true,       # ①: JavaScriptからdocument.cookieでのアクセスを禁止（XSS対策）
  secure: Rails.env.production?,  # ②: HTTPS通信時のみcookieを送信（盗聴リスク低減）
  same_site: :lax,     # CSRF対策: 同一サイトまたはトップレベルナビゲーションのみ送信
  expire_after: 1.hour # セッション有効期限
