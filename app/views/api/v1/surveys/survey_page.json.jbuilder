# frozen_string_literal: true

json.name @design.name

json.event do
  json.extract!(@event, :id, :name, :slug)
end

json.design do
  json.extract!(@design, :id, :name, :slug)
  json.pages_count @design.design_options.count
  json.current_page @page
end

json.design_option_id @design_option.id

if @design_option.section
  json.section do
    json.partial! "api/v1/surveys/section", section: @design_option.section
  end
elsif @design_option.variable
  json.variable do
    json.partial! "api/v1/surveys/variable", variable: @design_option.variable
  end
end

if @sheet_variable
  json.sheet_variable do
    json.partial! "api/v1/surveys/sheet_variable", sheet_variable: @sheet_variable
  end
end

if @sheet
  json.errors @sheet.errors
  json.response params[:response]
end
