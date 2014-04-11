Slice::Application.routes.draw do

  resources :comments

  get "survey", to: "survey#index", as: :about_survey
  get "survey/:slug", to: "survey#show"

  resources :projects, constraints: { format: /json|pdf|csv/ } do
    member do
      post :remove_file
      get :report
      post :report
      get :report_print
      get :subject_report
      post :filters
      post :new_filter
      post :edit_filter
      post :favorite
      get :activity
      get :explore
      get :share
      get :setup
      get :about
      post :transfer
      post :invite_user
    end

    collection do
      get :splash
      get :search
    end

    resources :contacts
    resources :documents
    resources :events

    resources :posts
    resources :links

    resources :sheets do
      member do
        get :print
        post :remove_file
        get :audits
        get :survey
        post :submit_survey
        post :unlock
      end
    end

    get "surveys/:id" => "designs#survey", as: :survey
    post "surveys/:id" => "sheets#submit_public_survey", as: :submit_public_survey

    resources :designs do
      member do
        get :copy
        get :print
        get :reorder
        post :update_order
        get :report
        post :report
        get :report_print
        post :progress
        get :reimport
        patch :update_import
        get :overview
      end
      collection do
        post :selection
        get :import
        post :create_import
        post :add_question
        get :json_import
        post :json_import_create
      end
    end

    resources :domains do
      collection do
        post :add_option
        post :values
      end
    end

    resources :exports do
      member do
        post :mark_unread
        post :progress
      end
    end

    resources :sites do
      collection do
        post :selection
      end
    end

    resources :site_users do
      member do
        post :resend
      end
      collection do
        get :accept
      end
    end

    resources :schedules do
      collection do
        post :add_event
        post :add_design
      end
    end

    resources :subjects do
      resources :subject_schedules
    end

    resources :variables do
      member do
        get :copy
        get :format_number
        post :add_grid_row
        get :typeahead
      end
      collection do
        post :add_grid_variable
        post :cool_lookup
      end
    end
  end

  resources :project_users do
    member do
      post :resend
    end
    collection do
      get :accept
    end
  end

  resources :reports


  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users do
    member do
      post :update_settings
    end
  end

  get "/about" => "application#about", as: :about
  get "/about/use" => "application#use", as: :about_use
  get "/settings" => "users#settings", as: :settings
  get "/search" => "projects#search", as: :search
  get "/activity" => "users#activity", as: :activity

  root to: 'projects#splash'

end
