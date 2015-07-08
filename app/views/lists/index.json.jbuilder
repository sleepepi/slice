json.array!(@lists) do |list|
  json.extract! list, :id, :project_id, :randomization_scheme_id, :user_id, :name, :deleted
  json.url list_url(list, format: :json)
end
