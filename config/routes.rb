Dash::Application.routes.draw do
  get "sessions/create"
  get "sessions/destroy"
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get 'login', to: 'users#login'

  root to: 'users#index'

  resources :sessions, only: [:create, :destroy]

  resources :users do
    member do
      post :update_availability
    end
    collection do
      post :available_members
    end
  end

  resources :games do
    member do
      post :play
      post :ready
      post :action
      post :opponent_decision
      delete :play
    end
  end

  resources :players do
    member do
      post :action
    end
  end
end
