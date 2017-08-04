# frozen_string_literal: true

json.extract!(
  variable, :id, :name, :display_name, :description, :variable_type, :units
)

json.domain_options do
  json.array!(variable.domain_options) do |domain_option|
    json.partial! "api/v1/surveys/domain_option", domain_option: domain_option
  end
end
