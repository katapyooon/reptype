Rails.application.config.session_store :cookie_store,
  key: "_reptype_session",
  httponly: true,
  secure: Rails.env.production?,
  same_site: :lax
