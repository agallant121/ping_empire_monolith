Rails.application.routes.draw do
  root "websites#index"

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords"
  }

  resource :language_preference, only: [ :update ]
  resource :profile, only: [ :show, :update ] do
    post :send_reset_password
    delete :disconnect_oauth
  end

  resources :websites do
    collection do
      get :failures
    end
    resources :responses
  end

  namespace :admin do
    resource :aws_settings, only: [ :show, :create, :update ], controller: "aws_settings"
    resources :archives, only: [ :index ] do
      collection do
        post :export
        post :upload
        get :download
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
