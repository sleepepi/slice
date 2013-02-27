json.array!(@projects) do |project|
  json.extract! project, :description, :name, :emails, :acrostic_enabled, :logo, :logo_uploaded_at, :logo_cache, :subject_code_name, :show_contacts, :show_documents, :show_posts, :user_id, :created_at, :updated_at
  json.path project_path(project, format: :json)
  # json.url project_url(project, format: :json)
end
