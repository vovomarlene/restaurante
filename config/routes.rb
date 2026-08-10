Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  namespace :admin do
    resources :categories
    resources :products
    resources :ingredients do
      resources :stock_movements, only: [ :index, :new, :create ]
    end
    resources :dining_tables
    resources :reports, only: [ :index ]
    resource :printer_setting, only: [ :edit, :update ]
  end

  get "mesas", to: "tables#index", as: :tables
  get "balcao", to: "balcao#index", as: :balcao

  resources :orders, only: [ :create, :show, :index ] do
    resources :order_items, only: [ :create, :destroy ]
    resources :payments, only: [ :new, :create ]
    member do
      get :receipt
      get :kitchen_ticket
      post :kitchen_ticket_confirm
      get :cancel
      post :cancel
      patch :toggle_service_fee
    end
  end

  resource :cash_session, path: "caixa", only: [ :show, :new, :create ]
  patch "caixa/fechar", to: "cash_sessions#close", as: :close_cash_session
  get "caixa/:id/resumo", to: "cash_sessions#summary", as: :cash_session_summary
  resources :cash_movements, only: [ :create ], path: "movimentos_caixa"

  resources :deliveries, only: [ :index, :new, :create ]
  patch "deliveries/:id/avancar", to: "deliveries#advance", as: :advance_delivery

  resources :customers do
    resources :fiado_settlements, only: [ :new, :create ]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
