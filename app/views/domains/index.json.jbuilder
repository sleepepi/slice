json.array!(@domains) do |domain|
  json.extract! domain, :name, :description, :options, :project_id, :user_id, :created_at, :updated_at
  json.path project_domain_path(domain.project, domain, format: :json)
  # json.url project_domain_url(domain.project, domain, format: :json)
end
