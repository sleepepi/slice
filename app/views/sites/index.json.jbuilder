json.array!(@sites) do |site|
  json.extract! site, :description, :emails, :name, :project_id, :prefix, :code_minimum, :code_maximum, :created_at, :updated_at
  json.path project_site_path(site.project, site, format: :json)
  # json.url project_site_url(site.project, site, format: :json)
end
