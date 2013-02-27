json.array!(@documents) do |document|
  json.extract! document, :archived, :category, :file, :name, :project_id, :user_id, :created_at, :updated_at
  json.path project_document_path(document.project, document, format: :json)
  # json.url project_document_url(document.project, document, format: :json)
end
