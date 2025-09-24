Rails.application.routes.draw do
  root "dashboards#show"

  devise_for :users

  resources :websites, except: [ :index ] do
    resources :responses
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
