Rails.application.routes.draw do
  # 公開するのは診断フローで実際に使うルートのみ。
  # マスタデータ(Type / Question / Result)は db/*_seeds.rb で管理するため、CRUD画面は公開しない。
  root "home#index"

  resources :questions, only: [ :index ] do
    member do
      post "answer"
    end
  end

  # likert_controller.js が1問回答するごとに保存する
  resources :answers, only: [ :create ]

  resources :results, only: [ :show, :create ] do
    member do
      get :export_pdf
      get :pdf_preview
    end
    resource :chat, only: [ :show, :create ]
    resources :morphs, only: [ :index, :show ], param: :code
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # 利用規約関連のルーティング
  get "terms", to: "footer#terms"
  get "privacy", to: "footer#privacy"
  get "inquiry", to: "footer#inquiry"
end
