Rails.application.routes.draw do

  resources :lists
  resources :comments

  get "survey", to: "survey#index", as: :about_survey
  get "survey/:slug", to: "survey#show"
  get "survey/:slug/sections/:section_id/image", to: "survey#section_image", as: :survey_section_image

  get "check-date", to: "application#check_date"

  resources :projects, constraints: { format: /json|pdf|csv/ } do
    member do
      get :report
      post :report
      get :report_print
      get :subject_report
      post :filters
      post :new_filter
      post :edit_filter
      post :favorite
      get :activity
      get :share
      get :setup
      get :about
      post :transfer
      post :invite_user
      get :logo
      post :archive
    end

    collection do
      get :splash
      get :search
      post :save_project_order
    end

    resources :contacts
    resources :documents do
      member do
        get :file
      end
    end

    resources :events do
      collection do
        post :add_design
      end
    end

    resources :posts
    resources :links

    resources :sheets do
      member do
        get :print
        get :file
        get :transactions
        get :survey
        post :submit_survey
        post :unlock
        get :double_data_entry
        get :verification_report
        get :transfer
        patch :transfer
        patch :move_to_event
      end
    end

    get "surveys/:id" => "designs#survey", as: :survey
    post "surveys/:id" => "sheets#submit_public_survey", as: :submit_public_survey

    resources :designs do
      member do
        get :copy
        get :print
        get :reorder
        post :update_section_order
        post :update_option_order
        get :report
        post :report
        get :report_print
        post :progress
        get :reimport
        patch :update_import
        get :overview
        get :master_verification
      end
      collection do
        post :selection
        get :import
        post :create_import
        post :add_question
        get :json_import
        post :json_import_create
      end

      resources :sections do
        member do
          get :image
        end
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
        get :file
        post :mark_unread
        post :progress
      end
    end

    resources :randomizations do
      collection do
        get "choose-scheme", action: :choose_scheme, as: :choose_scheme
      end
      member do
        patch :undo
      end
    end

    resources :randomization_schemes do
      member do
        get "randomize-subject", action: :randomize_subject, as: :randomize_subject
        get :subject_search
        post "randomize-subject", action: :randomize_subject_to_list, as: :randomize_subject_to_list
      end
      resources :block_size_multipliers
      resources :lists do
        collection do
          post :generate
          post :expand
        end
      end
      resources :stratification_factors do
        resources :stratification_factor_options
      end
      resources :treatment_arms
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
      member do
        get "choose-date/:event_id", action: :choose_date, as: :choose_date
        post :launch_subject_event
        get :choose_an_event_for_subject
        get :events
        get "events/:event_id/:subject_event_id/:event_date", action: :event, as: :event
        get "events/:event_id/:subject_event_id/:event_date/edit", action: :edit_event, as: :edit_event
        post "events/:event_id/:subject_event_id/:event_date", action: :update_event, as: :update_event
        delete "events/:event_id/:subject_event_id/:event_date", action: :destroy_event, as: :destroy_event
        get :timeline
        get :comments
        get :settings
        get :files
        get :sheets
        get :data_entry, path: 'data-entry'
        get :choose_event, path: 'choose-event'
      end
      collection do
        get :choose_site, path: 'choose-site'
        get :search
      end
    end

    resources :variables do
      member do
        get :copy
        get :format_number
        post :add_grid_row
        get :typeahead
        post :restore
      end
      collection do
        post :add_grid_variable
        post :add_question
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


  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'join', sign_in: 'login' }, path: ""

  resources :users do
    member do
      post :update_settings
      post :update_theme
    end
  end

  scope module: 'application' do
    get :about
    get :contact
    get :font
    get :use, path: '/about/use', as: :about_use
    get :theme
    get :version
  end

  scope module: 'projects' do
    get :archives
  end

  get "/settings" => "users#settings", as: :settings
  get "/search" => "projects#search", as: :search
  get "/activity" => "users#activity", as: :activity

  root to: 'projects#splash'

end
