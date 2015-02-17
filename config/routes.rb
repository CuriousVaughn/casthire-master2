Rails.application.routes.draw do
  root 'home#index'
  get 'home/wait', to: 'home#wait'

  resources :sessions
  resources :users
  resources :castings do
    member do
      get :join
      get :apply
      post :kick
      post :interview
      post :register
      get 'private/:private_id', action: 'private'
    end
  end
  post 'pusher/auth', to: 'pusher#auth'
  post 'pusher/channel', to: 'pusher#channel'
end
