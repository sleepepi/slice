json.extract! variable, :description, :name, :display_name, :variable_type, :display_name_visibility, :prepend, :append, :created_at, :updated_at,
                  # Integer and Numeric
                  :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
                  # Date
                  :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum,
                  # Date and Time
                  :show_current_button,
                  # Calculated
                  :calculation, :format,
                  # Integer and Numeric and Calculated
                  :units,
                  # Grid
                  :multiple_rows, :default_row_number,
                  # Autocomplete
                  :autocomplete_values,
                  # Radio and Checkbox
                  :alignment

json.domain do
  json.partial! 'domains/domain', domain: variable.domain if variable.domain
end

if variable.variable_type == 'grid'
  json.grid_variables do
    json.array!(variable.grid_variable_ids) do |grid_variable_id|
      if grid_variable = variable.project.variables.where.not( variable_type: 'grid' ).find_by_id(grid_variable_id)
        json.partial! 'variables/variable', variable: grid_variable
      end
    end
  end
end
