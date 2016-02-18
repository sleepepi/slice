# frozen_string_literal: true

Rails.application.routes.draw do
  get 'survey', to: 'survey#index', as: :about_survey
  get 'survey/:slug', to: 'survey#new', as: :new_survey
  get 'survey/:slug/:sheet_authentication_token', to: 'survey#edit', as: :edit_survey
  post 'survey/:slug', to: 'survey#create'
  patch 'survey/:slug/:sheet_authentication_token', to: 'survey#update'

  get 'check-date', to: 'application#check_date'

  resources :comments
  resources :lists

  resources :notifications do
    collection do
      patch :mark_all_as_read
    end
  end

  resources :projects, constraints: { format: /json|pdf|csv|js/ } do
    collection do
      get :splash
      get :search
      post :save_project_order
    end

    member do
      get :report
      post :report
      get :report_print
      get :subject_report
      get :reports
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

    resources :adverse_events, path: 'adverse-events' do
      collection do
        get :export
      end
      member do
        get :forms
      end
      resources :adverse_event_comments
      resources :adverse_event_files, path: 'files' do
        collection do
          post :upload, action: :create_multiple
        end
        member do
          get :download
        end
      end
    end

    resources :categories

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
        post :unlock
        get :double_data_entry
        get :verification_report
        get :transfer
        patch :transfer
        patch :move_to_event
      end
    end

    resources :designs do
      member do
        get :copy
        get :print
        get :reorder
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

      resources :sections

      resources :design_options do
        collection do
          get :new_section
          get :new_variable
          get :new_existing_variable
          post :create_section
          post :create_variable
          post :create_existing_variable
          post :update_section_order
          post :update_option_order
        end
        member do
          get :edit_variable
          get :edit_domain
          patch :update_domain
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
        get 'choose-scheme', action: :choose_scheme, as: :choose_scheme
      end
      member do
        patch :undo
      end
    end

    resources :randomization_schemes do
      collection do
        post :add_task
      end
      member do
        get 'randomize-subject', action: :randomize_subject, as: :randomize_subject
        get :subject_search
        post 'randomize-subject', action: :randomize_subject_to_list, as: :randomize_subject_to_list
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

    resources :subjects do
      member do
        get 'choose-date/:event_id', action: :choose_date, as: :choose_date
        post :launch_subject_event
        get :choose_an_event_for_subject
        get :events
        get 'events/:event_id/:subject_event_id/:event_date', action: :event, as: :event
        get 'events/:event_id/:subject_event_id/:event_date/edit', action: :edit_event, as: :edit_event
        post 'events/:event_id/:subject_event_id/:event_date', action: :update_event, as: :update_event
        delete 'events/:event_id/:subject_event_id/:event_date', action: :destroy_event, as: :destroy_event
        get :timeline
        get :comments
        get :settings
        get :files
        get :adverse_events, path: 'adverse-events'
        get :sheets
        get :data_entry, path: 'data-entry'
        get 'data-entry/:design_id', action: :new_data_entry, as: :new_data_entry
        get :choose_event, path: 'choose-event'
        get 'handoff/:subject_event_id', controller: :handoffs, action: :new, as: :new_handoff
        post 'handoff/:subject_event_id', controller: :handoffs, action: :create, as: :create_handoff
        get 'handoff', to: redirect('projects/%{project_id}/subjects/%{id}')
      end
      collection do
        get :choose_site, path: 'choose-site'
        get :search
      end
    end

    resources :tasks

    resources :variables do
      member do
        get :copy
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

  get 'invite/:invite_token' => 'project_users#invite'
  get 'site-invite/:site_invite_token' => 'site_users#invite'

  resources :reports

  devise_for :users,
             controllers: {
               registrations: 'contour/registrations',
               sessions:      'contour/sessions',
               passwords:     'contour/passwords',
               confirmations: 'contour/confirmations',
               unlocks:       'contour/unlocks'
             },
             path_names: {
               sign_up: 'join',
               sign_in: 'login'
             },
             path: ''

  resources :users do
    collection do
      get :invite
    end
  end

  scope module: :users do
    get :settings
    post :settings, action: :update_settings
    get :update_settings, to: redirect('settings')
    post :update_theme
    get :update_theme, to: redirect('settings')
    patch :change_password
    get :change_password, to: redirect('settings')
  end

  scope module: 'application' do
    get :about
    get :contact
    get :font
    get :use, path: '/about/use', as: :about_use
    get :theme
    get :version
  end

  namespace :external do
    post :add_grid_row
    get :typeahead
    get :format_number
    get :section_image
  end

  namespace :handoff do
    get ':project/:handoff', action: :start, as: :start
    get ':project/:handoff/:design', action: :design, as: :design
    post ':project/:handoff/:design', action: :save, as: :save
    get 'complete', action: :complete, as: :complete
    get 'completed', action: :completed, as: :completed
  end

  scope module: 'projects' do
    get :archives
  end

  namespace :timeout do
    get :check
  end

  namespace :validate do
    post :variable
  end

  get '/search' => 'projects#search', as: :search
  get '/activity' => 'users#activity', as: :activity

  root to: 'projects#splash'
end
