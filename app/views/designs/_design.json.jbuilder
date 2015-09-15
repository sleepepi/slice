json.extract! design, :name, :description

json.options do
  json.array!(design.design_options) do |design_option|
    json.partial! 'designs/design_option', design_option: design_option
  end
end
