Reading::Application.routes.draw do

  resources :designs do
    member do
      get :copy
    end
    collection do
      post :add_variable
      post :variables
      post :selection
    end
  end

  resources :projects

  resources :sheets do
    member do
      post :send_email
    end
  end

  resources :sites do
    collection do
      post :selection
    end
  end

  resources :subjects

  resources :variables do
    member do
      get :copy
    end
    collection do
      post :add_option
      post :options
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users

  match "/about" => "application#about", as: :about

  root to: 'sheets#index'

end
