Rails.application.routes.draw do
  root to: "welcome#index"
  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth_callbacks",
    registrations: 'registrations'
  }

  get 'welcome', to: 'welcome#index'
  get 'top', to: 'top#index'

  resources :settings, only: [:index] do
    collection do
      put '/', to: 'settings#update'
    end
  end
end
