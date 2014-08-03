Dash::Application.routes.draw do
  root to: 'users#new'

  resources :users do
    member do
      post :update_availability
    end
    collection do
      post :availability
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
