Reading::Application.routes.draw do

  resources :designs

  resources :projects

  resources :sheets

  resources :subjects

  resources :variables

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users

  match "/about" => "sites#about", as: :about
  match "/dashboard" => "sites#dashboard", as: :dashboard

  root to: 'sheets#index'

end
