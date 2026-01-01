Rails.application.routes.draw do
  # Devise authentication with custom controllers
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }

  # Authenticated routes
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  # Public root
  root "home#index"

  # Dashboard
  get 'dashboard', to: 'dashboard#index', as: 'dashboard'
  get 'dashboard/search', to: 'dashboard#search', as: 'dashboard_search'

  # Passwords
  resources :passwords do
    member do
      post :decrypt
      post :copy
    end
    collection do
      post :generate
      post :check_breach
    end
  end

  # Manager namespace
  namespace :manager do
    resources :users do
      member do
        patch :activate
        patch :deactivate
      end
    end
  end

  # Admin namespace
  namespace :admin do
    root to: "dashboard#index"

    get 'dashboard', to: 'dashboard#index', as: 'dashboard'

    resources :companies do
      member do
        get :statistics
      end
    end

    get 'analytics', to: 'analytics#index', as: 'analytics'
    get 'analytics/export', to: 'analytics#export', as: 'analytics_export'
  end

  # API namespace
  namespace :api do
    namespace :v1 do
      # User endpoints
      resource :user, only: [] do
        get :me, on: :collection
        patch :update_preferences, on: :collection
      end

      # Preferences endpoints
      resource :preferences, only: [] do
        patch :update_theme, action: :update_theme, path: 'theme'
      end

      # Dashboard endpoints
      get 'dashboard/stats', to: 'dashboard#stats', as: 'dashboard_stats'

      # Password endpoints
      resources :passwords do
        member do
          post :decrypt
        end
        collection do
          post :generate
          post :check_breach
        end
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
