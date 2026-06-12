Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show", as: :health
      get "bootstrap", to: "bootstrap#show", as: :bootstrap
      resources :plan_rules, only: [ :index, :show ]
      resources :knowledge_entries, only: [ :index, :show ]

      namespace :chat do
        resources :public_sessions, only: [ :create, :show ], param: :id do
          resources :messages, only: :create, controller: :public_messages
        end
      end

      namespace :admin do
        resources :audit_events, only: :index
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
