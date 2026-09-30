Rails.application.routes.draw do
  namespace :admin do
    root to: "profiles#edit"

    mount MissionControl::Jobs::Engine, at: "/jobs"

    post "masquerade/:id", to: "masquerades#create", as: :masquerade

    resources :collections
    resources :collection_links
    resources :places
    resources :sessions
    resources :users
    resources :payment_infos
    resources :waitlists
    resources :blog_posts

    resource :profile, only: [:edit, :update]
  end

  constraints Constraints::AuthenticatedUser do
    root to: "home#index", as: :authenticated_root
  end

  root "home#index"
  get "/home" => "home#index"
  get "terms_of_service" => "home#terms_of_service", :as => :tos
  get "privacy" => "home#privacy_policy", :as => :privacy
  get "up" => "rails/health#show", :as => :rails_health_check

  resource :subscription, only: [:create, :destroy] do
    get :success
    get :cancel
    get :update_payment_method
  end

  resource :session
  resources :passwords, param: :token
  resources :waitlists, only: [:create]
  resource :masquerade, only: [:destroy], controller: "masquerades"

  resources :collection_links, only: [:index, :show] do
    member do
      get "qr_code"
    end
  end

  resources :guides, only: [:show]

  namespace :api do
    namespace :stripe do
      mount StripeEvent::Engine, at: "/webhooks"
    end
  end

  get "/blog/:locale", to: "blog_posts#index", as: :blog
  get "/blog/:locale/:slug", to: "blog_posts#show", as: :blog_post
  get "/blog", to: redirect { |path_params, req| "/blog/#{req.params[:locale] || I18n.locale}" }
  get "/authors/:slug", to: "authors#show", as: :author

  namespace :collections do
    resources :purchases, only: [] do
      collection do
        get :checkout, action: :create
        get :success
      end
    end
  end
  resources :collections, only: [:show]

  # Render dynamic PWA files from app/views/pwa/*
  get "manifest" => "rails/pwa#manifest", :as => :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", :as => :pwa_service_worker

  get "/c/:id", to: "collection_links#show", as: :short_collection_link
  get "/u/:id", to: "guides#show", as: :short_guide
end
