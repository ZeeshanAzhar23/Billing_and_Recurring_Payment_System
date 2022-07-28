Rails.application.routes.draw do
  devise_for :users
  root 'home#welcome'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:index,:destroy,:show,:update,:edit]
  resources :plans do
    resources :features
  end
  namespace :purchase do
    resources :checkouts
  end
  resources :subscriptions
  get "success", to: "purchase/checkouts#success"
  resources :webhooks, only: [:create]
  resources :billings, only: :create
end
