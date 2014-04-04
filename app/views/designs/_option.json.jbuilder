if option[:section_name].blank?
  variable = @project.variables.find_by_id(option[:variable_id])
  if variable
    json.variable do
      json.partial! 'variables/variable', variable: variable
    end
  end
else
  json.section_name option[:section_name].to_s
  json.section_id option[:section_id].to_s
  json.section_description option[:section_description].to_s
  json.section_type option[:section_type].to_s
end
json.branching_logic option[:branching_logic].to_s
