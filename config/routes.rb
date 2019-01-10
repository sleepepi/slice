# frozen_string_literal: true

Rails.application.routes.draw do
  root "account#dashboard"

  get "survey", to: "survey#index", as: :about_survey
  get "survey/:slug", to: "survey#new", as: :new_survey
  get "survey/:slug/:sheet_authentication_token", to: "survey#edit", as: :edit_survey
  post "survey/:slug", to: "survey#create", as: :create_survey
  patch "survey/:slug/:sheet_authentication_token", to: "survey#update", as: :update_survey
  get "adverse-event/:authentication_token", to: "adverse_event#show", as: :adverse_event_show
  post "adverse-event/:authentication_token/review", to: "adverse_event#review", as: :adverse_event_review

  scope module: :account do
    get :dashboard
  end

  namespace :ae_module, path: "projects/:project_id/ae-module" do
    root action: :dashboard
    get :dashboard

    resources :adverse_events, path: "adverse-events" do
      member do
        get :log
      end
    end

    resources :documents, path: "adverse-events/:adverse_event_id/documents", except: [:edit, :update] do
      collection do
        post :upload_files, path: "upload-files"
      end

      member do
        get :download
      end
    end

    resources :info_requests, path: "adverse-events/:adverse_event_id/info-requests", except: [:edit, :update] do
      member do
        post :resolve
      end
    end

    resources :sheets, path: "adverse-events/:adverse_event_id/sheets", only: [:show] do

    end

    namespace :reporters do
      get :form, path: "adverse-events/:id/form/:design_id"
      post :form_save, path: "adverse-events/:id/form/:design_id"
      post :send_for_review, path: "adverse-events/:id/send-for-review"
    end

    namespace :admins do
      get :setup_designs, path: "setup-designs"
      post :submit_designs, path: "submit-designs"
      post :assign_team, path: "adverse-events/:id/assign-team"
      delete :remove_designment, path: "remove-designment"
      get :form, path: "adverse-events/:id/form/:design_id"
      post :form_save, path: "adverse-events/:id/form/:design_id"
      get :sheet, path: "adverse-events/:id/sheets/:sheet_id"
      post :close_adverse_event, path: "adverse-events/:id/close"
      post :reopen_adverse_event, path: "adverse-events/:id/reopen"
    end

    namespace :managers do
      get :inbox
      get :determine_pathway, path: "teams/:team_id/adverse-events/:id/assignments"
      post :assign_reviewers, path: "teams/:team_id/adverse-events/:id/assign-reviewers"
      post :team_review_completed, path: "teams/:team_id/adverse-events/:id/team-review-completed"
      post :team_review_uncompleted, path: "teams/:team_id/adverse-events/:id/team-review-uncompleted"
    end

    namespace :reviewers do
      get :dashboard
      get :inbox
      get :review, path: "assignments/:assignment_id/reviews/:design_id"
      post :review_save, path: "assignments/:assignment_id/reviews/:design_id"
      # get :sheet_new, path: "assignments/:assignment_id/reviews/:design_id"
      get :sheet, path: "assignments/:assignment_id/sheets/:sheet_id"
      get :sheet_edit, path: "assignments/:assignment_id/sheets/:sheet_id/edit"
      post :sheet_create, path: "assignments/:assignment_id/sheets"
      patch :sheet_update, path: "assignments/:assignment_id/sheets/:sheet_id"
    end
  end

  get :settings, to: redirect("settings/profile")
  namespace :settings do
    get :profile
    patch :update_profile, path: "profile"
    patch :complete_profile, path: "complete-profile"
    get :profile_picture, path: "profile/picture", to: redirect("settings/profile")
    patch :update_profile_picture, path: "profile/picture"

    get :account
    patch :update_account, path: "account"
    get :password, to: redirect("settings/account")
    patch :update_password, path: "password"
    delete :destroy, path: "account", as: "delete_account"

    get :email
    patch :update_email, path: "email"

    get :notifications
    patch :update_notifications, path: "notifications"

    get :interface
    patch :update_interface, path: "interface"
  end

  get :admin, to: "admin#dashboard"
  namespace :admin do
    resources :engine_runs, path: "engine-runs"
  end

  namespace :api do
    namespace :v1 do
      get "projects/:authentication_token", to: "projects#show", as: :project
      get "projects/:authentication_token/survey-info", to: "projects#survey_info", as: :survey_info
      get "projects/:authentication_token/subjects", to: "subjects#index", as: :subjects
      get "projects/:authentication_token/subjects/:id", to: "subjects#show", as: :subject
      get "projects/:authentication_token/subjects/:id/events", to: "subjects#events", as: :subject_events
      get "projects/:authentication_token/subjects/:id/data", to: "subjects#data", as: :subject_data
      post "projects/:authentication_token/subjects", to: "subjects#create", as: :create_subject
      post "projects/:authentication_token/subjects/:id/events", to: "subjects#create_event", as: :create_event
      post "projects/:authentication_token/subjects/:id/sheets", to: "subjects#create_sheet", as: :create_sheet

      get "projects/:authentication_token/subjects/:id/surveys/:event/:design", to: "surveys#show_survey", as: :show_survey
      get "projects/:authentication_token/subjects/:id/surveys/:event/:design/resume", to: "surveys#resume_survey", as: :resume_survey
      get "projects/:authentication_token/subjects/:id/surveys/:event/:design/:page", to: "surveys#show_survey_page", as: :show_survey_page
      patch "projects/:authentication_token/subjects/:id/surveys/:event/:design/:page", to: "surveys#update_survey_response", as: :update_survey_response

      namespace :reports, path: "projects/:authentication_token/reports" do
        get :show, path: ":event/:design"
        get :review, path: "review/:event/:design"
      end
    end
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

  resources :notifications do
    collection do
      patch :mark_all_as_read
    end
  end

  resources :organizations

  resources :profiles do
    member do
      get :picture
    end
  end

  namespace :owner do
    resources :projects, only: :destroy do
      member do
        get :api
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
        member do
          post :request_run, path: "request-run"
        end

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

  resources :projects, only: [:index, :show, :new, :create], constraints: { format: /json|pdf|csv|js/ } do
    collection do
      get :search
      post :save_project_order
    end

    member do
      get :activity
      get :calendar
      get :logo
      get :reports
      get :team
      get :expressions
      post :expressions_engine, path: "expressions/engine"
      get :expressions_search, path: "expressions/search"
      post :archive
      get :advanced, to: redirect("editor/projects/%{id}/advanced")
      get :settings, to: redirect("editor/projects/%{id}/settings")
    end

    namespace :reports do
      get "designs/:id/basic", controller: :designs, action: :basic, as: :design_basic
      get "designs/:id/overview", controller: :designs, action: :overview, as: :design_overview
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
        get :calculations
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
        post "imports/progress" => "imports/progress", as: :progress_import
        get "imports/edit" => "imports#edit", as: :edit_import
        patch "imports" => "imports#update", as: :update_import
      end

      collection do
        post :selection
        post :add_question
        get "imports/new" => "imports#new", as: :new_import
        post "imports" => "imports#create", as: :create_import
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

        get :edit_randomization, path: "randomizations/:randomization_id/edit"
        patch :update_randomization, path: "randomizations/:randomization_id"
        delete :destroy_randomization, path: "randomizations/:randomization_id"
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

  get "invite/:invite_token" => "project_users#invite", as: :invite
  get "site-invite/:site_invite_token" => "site_users#invite", as: :site_invite

  devise_for :users,
             controllers: {
               passwords: "passwords",
               registrations: "registrations",
               sessions: "sessions",
               unlocks: "unlocks"
             },
             path_names: { sign_up: "join", sign_in: "login" },
             path: ""

  resources :users

  scope module: :search do
    get :search, action: :index
  end

  scope module: :external do
    get :about
    get :contact
    get :landing
    get :privacy_policy, path: "privacy-policy"
    get :sitemap_xml, path: "sitemap.xml.gz"
    get :terms_of_service, path: "terms-of-service"
    get :use, path: "/about/use", as: :about_use
    get :version
  end

  resources :trays, path: "library/:username/trays" do
    resources :cubes do
      resources :faces do
        collection do
          post :positions
        end
      end

      collection do
        post :positions
        delete :destroy_all, path: ""
      end
    end
  end

  get "orgs/:username/members" => "library#members", as: :library_members

  namespace :library do
    root action: :index
    get :print, path: ":username/:id.pdf"
    get :tray, path: ":username/:id"
    get :profile, path: ":username"
  end

  namespace :external do
    post :add_grid_row
    get :section_image
  end

  scope module: :internal do
    post :keep_me_active, path: "keep-me-active"
    get :autocomplete
  end

  namespace :handoff do
    get ":project/:handoff", action: :start, as: :start
    get ":project/:handoff/:design", action: :design, as: :design
    post ":project/:handoff/:design", action: :save, as: :save
    get "completed", action: :completed, as: :completed
  end

  resources :members do
    member do
      get :profile_picture
    end
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

  namespace :themes do
    get :dashboard_test, path: "dashboard-test"
    get :full_test, path: "full-test"
    get :menu_test, path: "menu-test"
    get :transition_test, path: "transition-test"
  end
end
