# frozen_string_literal: true

json.event do
  json.extract!(@event, :id, :name, :slug)
end
json.design do
  json.extract!(@design, :id, :name, :slug)
  json.pages_count @design.design_options.count
end

json.sheet_count @sheets.count

json.design_options do
  json.array!(@design.design_options.includes(:variable, :section)) do |design_option|
    if design_option&.section&.display_on_report?
      json.partial! "api/v1/reports/section", design_option: design_option, section: design_option.section
    elsif design_option&.variable
      json.partial! "api/v1/reports/variable", design_option: design_option, variable: design_option.variable
    end
  end
end
