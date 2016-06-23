Rails.application.routes.draw do
  devise_for :users
  root to: "welcome#index"

  get 'welcome', to: 'welcome#index'
  get 'top', to: 'top#index'
end
