Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      devise_for :api_clients, skip: [:sessions, :registrations, :confirmations]
      resources :domains do
        resources :records do
          delete '/', on: :collection, action: :delete_all
        end
      end
    end
  end

  devise_for :users, :controllers => { :sessions => "sessions" }, :path => "sessions"

  root :to => 'dashboard#index'

  resources :domains do
    member do
      put :change_owner
      get :apply_macro
      post :apply_macro
      put :update_note
    end

    resources :records do
      member do
        put :update_soa
      end
    end
  end

  resources :zone_templates, :controller => 'templates'
  resources :record_templates

  resources :macros do
    resources :macro_steps
  end

  # get '/audits(/:action(/:id))' => 'audits#index', :as => :audits
  resources :audits, only: :index do
    get "/domain/:id", action: :domain, on: :collection
  end

  resources :reports, only: :index do
    collection do
      get :results
      get :view
    end
  end

  # get '/search(/:action)' => 'search#results', :as => :search
  resource :search, controller: :search, only: :show do
    get :results
  end


  resource :auth_token
  post '/token/:token' => 'sessions#token', :as => :token

  resources :users do
    member do
      put :suspend
      put :unsuspend
      delete :purge
    end
  end

  resources :api_clients

  #match '/logout' => 'sessions#destroy', :as => :logout
end
