Rails.application.routes.draw do
  root to: "welcome#index"
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations:      'users/registrations',
    sessions:           'users/sessions'
  }

  get 'welcome', to: 'welcome#index'
  get 'top', to: 'top#index'

  resources :settings, only: [:index] do
    collection do
      put '/', to: 'settings#update'
    end
  end
end
