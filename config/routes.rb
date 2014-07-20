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
end
