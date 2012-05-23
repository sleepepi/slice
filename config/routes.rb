Reading::Application.routes.draw do

  resources :designs do
    collection do
      post :add_variable
      post :variables
      post :selection
    end
  end

  resources :projects

  resources :sheets

  resources :subjects

  resources :variables do
    collection do
      post :add_option
      post :options
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users

  match "/about" => "sites#about", as: :about
  match "/dashboard" => "sites#dashboard", as: :dashboard

  root to: 'sheets#index'

end
