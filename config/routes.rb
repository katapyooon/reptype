Rails.application.routes.draw do
  resources :answers
  # root must use the controller#action form
  get "home/index"
  root "home#index"
  resources :questions do
    member do
      post "answer"
    end
  end

  ## results
  # Keep legacy named helper `results_index_path` / `results_index_url` for tests
  get "results/index", to: "results#index", as: :results_index
  resources :results, only: [ :index, :show, :create, :edit, :update, :destroy ]

  resources :types

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # 利用規約関連のルーティング
  get "terms", to: "footer#terms"
  get "privacy", to: "footer#privacy"
  get "inquiry", to: "footer#inquiry"
end
