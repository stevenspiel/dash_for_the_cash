Dash::Application.routes.draw do
  root to: 'users#new'
  resources :users 

  resources :games do
    member do
      post :play
      delete :play
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
