# frozen_string_literal: true

json.event do
  json.extract!(@event, :id, :name, :slug)
end
json.design do
  json.extract!(@design, :id, :name, :slug)
end

design_option_skip_count = {}
design_options = []
last_design_option_id = nil
skip_count = 0
@sheet.design.design_options.includes(:design, :section, variable: { domain: :domain_options }).each do |design_option|
  if @sheet.show_design_option?(design_option.branching_logic)
    design_options << design_option
    if design_option&.variable
      design_option_skip_count[last_design_option_id.to_s] = skip_count if last_design_option_id
      last_design_option_id = design_option.id
      skip_count = 0
    end
  else
    skip_count += 1 if design_option&.variable
  end
end

design_option_skip_count[last_design_option_id.to_s] = skip_count if last_design_option_id

page = 0
json.design_options do
  json.array!(design_options) do |design_option|
    page += 1
    if design_option&.section&.display_on_report?
      json.partial! "api/v1/reports/section", design_option: design_option, section: design_option.section
    elsif design_option&.variable
      json.page page
      json.skip_count design_option_skip_count[design_option.id.to_s]
      json.partial! "api/v1/reports/review/variable", design_option: design_option, variable: design_option.variable
    end
  end
end
