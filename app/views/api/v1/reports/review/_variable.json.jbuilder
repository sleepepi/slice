# frozen_string_literal: true

json.extract!(
  variable, :id, :name, :display_name, :description, :variable_type, :units,
  :prepend, :append, :field_note, :time_duration_format, :time_of_day_format,
  :show_current_button, :date_format, :show_seconds
)

sheet_variable = @sheet&.sheet_variables&.find_by(variable: variable)
json.subject_response sheet_variable&.get_response(:raw)

case variable.variable_type
when "checkbox"
  json.domain_options do
    json.array!(variable.domain_options) do |domain_option|
      json.partial! "api/v1/reports/domain_option", domain_option: domain_option
    end
  end
when "radio", "dropdown"
  json.domain_options do
    json.array!(variable.domain_options.where(missing_code: false)) do |domain_option|
      json.partial! "api/v1/reports/domain_option", domain_option: domain_option
    end
  end
end
