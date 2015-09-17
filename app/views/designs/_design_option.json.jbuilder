if section = design_option.section
  json.section do
    json.name section.name
    json.description section.description
    json.sub_section section.sub_section?
  end
elsif variable = design_option.variable
  json.variable do
    json.partial! 'variables/variable', variable: variable
  end
end
json.branching_logic design_option.branching_logic
json.required design_option.required
