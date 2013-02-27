json.array!(@contacts) do |contact|
  json.extract! contact, :email, :fax, :name, :phone, :position, :user_id, :title, :project_id, :archived, :created_at, :updated_at
  json.path project_contact_path(contact.project, contact, format: :json)
  # json.url project_contact_url(contact.project, contact, format: :json)
end
