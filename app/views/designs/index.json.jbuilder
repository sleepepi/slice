json.array!(@designs) do |design|
  json.partial! 'designs/design', design: design

  json.path project_design_path(design.project, design, format: :json)
  # json.url project_design_url(design.project, design, format: :json)
end
