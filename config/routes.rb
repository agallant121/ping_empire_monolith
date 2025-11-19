Rails.application.routes.draw do
  root "websites#index"

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

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
