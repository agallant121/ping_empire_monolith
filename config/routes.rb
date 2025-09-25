Rails.application.routes.draw do
  root "dashboards#show"

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :websites, except: [:index] do
    resources :responses
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
