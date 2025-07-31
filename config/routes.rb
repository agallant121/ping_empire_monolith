Rails.application.routes.draw do
  devise_for :users
  root "websites#index"

  resources :websites do
    resources :responses
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
