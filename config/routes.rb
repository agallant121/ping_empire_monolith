Rails.application.routes.draw do
  root "websites#index"

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :websites do
    resources :responses
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
