json.array!(@users) do |user|
  json.extract! user, :first_name, :last_name, :email, :status, :created_at, :updated_at
  json.path user_path(user, format: :json)
  # json.url user_url(user, format: :json)
end
