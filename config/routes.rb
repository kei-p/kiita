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
      get 'mine'
    end
  end

  get :search, to: 'search#index'

  resources :users, only: [:show] do
    member do
      get 'followers'
      post 'follow'
      delete 'unfollow'
    end

    resources :items, except: [:new, :create] do
      member do
        post 'stock'
        delete 'unstock'
      end
    end
  end

  resources :drafts

  resources :tags, only: [:index, :show]

  resources :settings, only: [:index] do
    collection do
      put '/', to: 'settings#update'
    end
  end
end
