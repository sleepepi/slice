Slice::Application.routes.draw do

  mount MailPreview => 'mail_view' if Rails.env.development?

  resources :exports do
    member do
      post :mark_unread
    end
  end

  resources :projects do
    member do
      post :remove_file
      get :report
      post :report
      get :subject_report
      get :settings
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
        post :send_email
        get :print
        post :remove_file
        get :audits
        get :survey
        post :submit_survey
      end
    end

    get "sheet_emails/show"

    resources :designs do
      member do
        get :copy
        get :print
        post :reorder
        get :report
        post :report
        get :reporter
        post :reporter
        get :report_print
      end
      collection do
        post :add_variable
        post :add_section
        post :variables
        post :selection
        get :batch
        post :create_batch
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
        # post :add_option
        # post :options
        post :add_grid_variable
      end
    end
  end

  resources :sheet_emails

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

  resources :users

  get "/about" => "application#about", as: :about
  get "/about/use" => "application#use", as: :about_use
  get "/settings" => "users#settings", as: :settings
  get "/search" => "projects#search", as: :search

  root to: 'projects#splash'

end
