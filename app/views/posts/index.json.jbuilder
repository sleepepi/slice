json.array!(@posts) do |post|
  json.extract! post, :archived, :description, :name, :project_id, :user_id, :created_at, :updated_at
  json.path project_post_path(post.project, post, format: :json)
  # json.url project_post_url(post.project, post, format: :json)
end
