Rails.application.routes.draw do
  root to: "welcome#index"
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations:      'users/registrations',
    sessions:           'users/sessions'
  }

  get 'welcome', to: 'welcome#index'
  resource 'top', only: [:show] do
    member do
      get 'feed'
      get 'items'
      get 'stock'
    end
  end

  resources :users, only: [:show] do
    resources :items do
      member do
        post 'stock'
        delete 'unstock'
      end
    end
  end

  resources :tags, only: [:index, :show]

  resources :settings, only: [:index] do
    collection do
      put '/', to: 'settings#update'
    end
  end
end
