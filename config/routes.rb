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
      post :bulk_create
      get :failures
    end
    resources :responses
  end

  namespace :admin do
    root to: "dashboard#show"
    resource :aws_settings, only: [ :show, :create, :update ], controller: "aws_settings"
    resources :archives, only: [ :index ] do
      collection do
        post :export
        post :upload
        get :download
      end
    end
    resources :users, only: [ :index, :create, :destroy, :update ], controller: "users"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
