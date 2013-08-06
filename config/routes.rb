Slice::Application.routes.draw do

  mount MailPreview => 'mail_view' if Rails.env.development?

  resources :comments

  resources :exports do
    member do
      post :mark_unread
      post :progress
    end
  end

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
    end

    collection do
      get :splash
      get :search
    end

    resources :contacts
    resources :documents
    resources :posts
    resources :links

    resources :sheets do
      collection do
        post :project_selection
      end
      member do
        get :print
        post :remove_file
        get :audits
        get :survey
        post :submit_survey
      end
    end

    get "surveys/:id" => "designs#survey", as: :survey
    post "surveys/:id" => "sheets#submit_public_survey", as: :submit_public_survey

    resources :designs do
      member do
        get :copy
        get :print
        post :reorder
        get :report
        post :report
        get :reporter
        post :reporter
        get :reporter_print
        get :blank
        post :blank
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
      end
    end

    resources :domains do
      collection do
        post :add_option
        post :values
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

    resources :subjects

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

  root to: 'projects#splash'

end
