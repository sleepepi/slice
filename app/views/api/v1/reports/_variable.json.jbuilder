# frozen_string_literal: true

json.extract!(
  variable, :id, :name, :display_name, :description, :variable_type, :units,
  :prepend, :append, :field_note, :time_duration_format, :time_of_day_format,
  :show_current_button, :date_format, :show_seconds
)

if @subject
  sheet = @sheets.find_by(subject: @subject)
  sheet_variable = sheet&.sheet_variables.find_by(variable: variable)
  json.subject_response sheet_variable&.get_response(:raw)
end

case variable.variable_type
when "checkbox"
  json.chart_type "pie"
  json.response_count @sheets.count
  responses = @sheets.sheet_responses_for_checkboxes(variable)
  json.domain_options do
    json.array!(variable.domain_options) do |domain_option|
      json.partial! "api/v1/reports/domain_option", domain_option: domain_option
      json.count responses.select { |r| r == domain_option.value }.count
    end
  end
when "radio", "dropdown"
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
when "imperial_height", "imperial_weight", "numeric", "integer"
  responses = @sheets.sheet_responses(variable).sort
  json.responses responses
end
