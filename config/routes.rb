# frozen_string_literal: true

Rails.application.routes.draw do
  root "account#dashboard"

  get "survey", to: "survey#index", as: :about_survey
  get "survey/:slug", to: "survey#new", as: :new_survey
  get "survey/:slug/:sheet_authentication_token", to: "survey#edit", as: :edit_survey
  post "survey/:slug", to: "survey#create", as: :create_survey
  patch "survey/:slug/:sheet_authentication_token", to: "survey#update", as: :update_survey
  get "adverse-event/:authentication_token", to: "adverse_event#show"
  post "adverse-event/:authentication_token/review", to: "adverse_event#review", as: :adverse_event_review

  scope module: :account do
    get :dashboard
    get :settings
    post :settings, action: :update_settings
    get :update_settings, to: redirect("settings")
    patch :change_password
    get :change_password, to: redirect("settings")
  end

  resources :comments

  get "docs", to: "docs#index", as: :docs
  namespace :docs do
    get :modules
    get :adverse_events, path: "adverse-events"
    get :tablet_handoff, path: "tablet-handoff"
    get :technical
    get :randomization_schemes, path: "randomization-schemes"
    get :minimization, path: "randomization-schemes/minimization"
    get :permuted_block, path: "randomization-schemes/permuted-block"
    get :roles, path: "project-roles"
    get :notifications
    get :blinding
    get :sites

    get :designs
    get :sections
    get :variables
    get :domains
    get :treatment_arms, path: "randomization/treatment-arms"
    get :stratification_factors, path: "randomization/stratification-factors"
    get :checks, path: "data-quality-checks"
    get :exports
    get :reports
    get :sheets, path: "data-entry"
    get :locking, path: "data-entry/locking"
    get :events, path: "data-entry/events"
    get :project_setup, path: "project-setup"
    get :lingo
    get :data_review, path: "data-review-and-analysis"
    get :filters
    get :theme
  end

  resources :lists

  resources :notifications do
    collection do
      patch :mark_all_as_read
    end
  end

  namespace :owner do
    resources :projects, only: :destroy do
      member do
        post :transfer
      end
    end
  end

  namespace :editor do
    resources :projects, only: [:edit, :update] do
      member do
        post :invite_user
        get :settings
        get :invite
        post :add_invite_row, path: "add-site-row"
        post :send_invites, path: "send-invites"
        get :advanced
      end

      resources :checks do
        resources :check_filters, path: "filters" do
          resources :check_filter_values, path: "values"
        end
      end

      resources :grid_variables, path: "grid-variables"
    end
  end

  namespace :project_preferences, path: "preferences" do
    patch :update
  end

  namespace :reports do
    resources :projects, only: [] do
      member do
        get :report
        post :report
        get :reports
        post :filters
        post :new_filter
        post :edit_filter
      end
    end
  end

  resources :projects, only: [:index, :show, :new, :create], constraints: { format: /json|pdf|csv|js/ } do
    collection do
      get :search
      post :save_project_order
    end

    member do
      post :favorite
      get :activity
      get :team
      get :logo
      post :archive
      get :advanced, to: redirect("editor/projects/%{id}/advanced")
      get :settings, to: redirect("editor/projects/%{id}/settings")
      get :calendar
    end

    namespace :reports do
      get "designs/:id/basic", controller: :designs, action: :basic, as: :design_basic
      get "designs/:id/overview", controller: :designs, action: :overview, as: :design_overview
      get "designs/:id/advanced", controller: :designs, action: :advanced, as: :design_advanced
      post "designs/:id/advanced", controller: :designs, action: :advanced_report
    end

    resources :adverse_events, path: "adverse-events" do
      collection do
        get :export
      end
      member do
        get :forms
        post :set_shareable_link
        post :remove_shareable_link
      end
      resources :adverse_event_comments, path: "comments"
      resources :adverse_event_files, path: "files" do
        collection do
          post :upload, action: :create_multiple
        end
        member do
          get :download
        end
      end
    end

    resources :categories

    resources :events do
      collection do
        post :add_design
      end
    end

    resources :sheets do
      collection do
        get :search
      end

      member do
        post :coverage
        get :file
        get :transactions
        post :unlock
        get :reassign
        patch :reassign
        patch :move_to_event
        post :remove_shareable_link
        post :unlock
        post :set_as_not_missing
      end

      resources :sheet_unlock_requests, path: "unlock/requests"
    end

    resources :designs do
      member do
        get :print
        get :reorder
        post "imports/progress" => "imports/progress"
        get "imports/edit" => "imports#edit"
        patch "imports" => "imports#update"
      end

      collection do
        post :selection
        post :add_question
        get "imports/new" => "imports#new"
        post "imports" => "imports#create"
      end

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
      resources :domain_options, path: "options"

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
        get :export
      end
      member do
        get :schedule
        patch :undo
      end
    end

    resources :randomization_schemes, path: "schemes" do
      collection do
        post :add_task
      end
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
        resources :stratification_factor_options, path: "options"
      end
      resources :treatment_arms
    end

    resources :sites do
      collection do
        get :setup
        post :add_site_row, path: "add-site-row"
        post :create_sites, path: "create-sites"
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
        get "choose-date/:event_id", action: :choose_date, as: :choose_date
        post :launch_subject_event
        get :events
        get "events/:event_id/:subject_event_id/:event_date", action: :event, as: :event
        get "events/:event_id/:subject_event_id/:event_date/edit", action: :edit_event, as: :edit_event
        post "events/:event_id/:subject_event_id", action: :update_event, as: :update_event
        delete "events/:event_id/:subject_event_id/:event_date", action: :destroy_event, as: :destroy_event
        get :timeline
        get :comments
        get :files
        get :adverse_events, path: "adverse-events"
        get :sheets
        get :data_entry, path: "data-entry"
        get "data-entry/:design_id", action: :new_data_entry, as: :new_data_entry
        post "data-missing/:design_id/:subject_event_id", action: :set_sheet_as_missing, as: :set_sheet_as_missing
        get :send_url, path: "send-url"
        post :set_sheet_as_shareable
        get :choose_event, path: "choose-event"
        get "handoff/:subject_event_id", controller: :handoffs, action: :new, as: :new_handoff
        post "handoff/:subject_event_id", controller: :handoffs, action: :create, as: :create_handoff
        get "handoff", to: redirect("projects/%{project_id}/subjects/%{id}")
        post :event_coverage
      end
      collection do
        get :choose_site, path: "choose-site"
        get :search
        get :autocomplete
        get :designs_search
        get :events_search
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
        post :report_lookup
        get :search
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

  get "invite/:invite_token" => "project_users#invite"
  get "site-invite/:site_invite_token" => "site_users#invite"

  devise_for :users, path_names: { sign_up: "join", sign_in: "login" }, path: ""

  resources :users do
    collection do
      get :invite
    end
  end

  scope module: :search do
    get :search, action: :index
  end

  scope module: :application do
    get :about
    get :contact
    get :use, path: "/about/use", as: :about_use
    get :version
  end

  scope module: :external do
    get :landing
  end

  get "sitemap.xml.gz" => "external#sitemap_xml"

  namespace :external do
    post :add_grid_row
    get :section_image
  end

  scope module: :internal do
    post :keep_me_active, path: "keep-me-active"
  end

  namespace :handoff do
    get ":project/:handoff", action: :start, as: :start
    get ":project/:handoff/:design", action: :design, as: :design
    post ":project/:handoff/:design", action: :save, as: :save
    get "completed", action: :completed, as: :completed
  end

  namespace :timeout do
    get :check
  end

  namespace :validate do
    post :variable
  end

  get "/activity" => "users#activity", as: :activity

  get "reports/projects", to: redirect("")
  get "reports", to: redirect("")
end
