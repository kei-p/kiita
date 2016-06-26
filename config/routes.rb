Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth_callbacks",
    registrations: 'registrations'
  }
  root to: "welcome#index"

  get 'welcome', to: 'welcome#index'
  get 'top', to: 'top#index'
end
