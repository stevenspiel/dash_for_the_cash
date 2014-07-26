Dash::Application.routes.draw do
  root to: 'users#new'

  resources :users do
    collection do
      post :availability
    end
  end

  resources :games do
    member do
      post :play
      post :action
      post :opponent_decision
    end
  end

  resources :players do
    member do
      post :action
    end
  end
end
