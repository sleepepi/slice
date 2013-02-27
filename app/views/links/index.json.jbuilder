json.array!(@links) do |link|
  json.extract! link, :archived, :category, :deleted, :name, :project_id, :url, :user_id, :created_at, :updated_at
  json.path project_link_path(link.project, link, format: :json)
  # json.url project_link_url(link.project, link, format: :json)
end
