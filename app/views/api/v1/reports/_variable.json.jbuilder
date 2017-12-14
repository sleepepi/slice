# frozen_string_literal: true

json.extract!(
  variable, :id, :name, :display_name, :description, :variable_type, :units,
  :prepend, :append, :field_note, :time_duration_format, :time_of_day_format,
  :show_current_button, :date_format, :show_seconds
)

if variable.variable_type == "checkbox"
  json.chart_type "pie"
  json.response_count @sheets.count
  responses = @sheets.sheet_responses_for_checkboxes(variable)
  json.domain_options do
    json.array!(variable.domain_options) do |domain_option|
      json.partial! "api/v1/reports/domain_option", domain_option: domain_option
      json.count responses.select { |r| r == domain_option.value }.count
    end
  end
elsif variable.variable_type == "radio"
  responses = @sheets.sheet_responses(variable)
  missing_codes = variable.missing_codes
  # blank_responses = responses.select(&:blank?)
  # missing_responses = responses.select{ |r| r.blank? || missing_codes.include?(r) }
  # valid_responses = responses.reject{ |r| r.blank? || missing_codes.include?(r) }.map(&:to_i)
  json.domain_options do
    json.array!(variable.domain_options.where(missing_code: false)) do |domain_option|
      json.partial! "api/v1/reports/domain_option", domain_option: domain_option
      json.count responses.select { |r| r == domain_option.value }.count
    end
  end
end
