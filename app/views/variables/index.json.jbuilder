json.array!(@variables) do |variable|
  json.extract! variable, :description, :name, :display_name, :variable_type, :project_id, :updater_id, :display_name_visibility, :prepend, :append, :created_at, :updated_at,
                  # Integer and Numeric
                  :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
                  # Date
                  :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum,
                  # Date and Time
                  :show_current_button,
                  # Time and Time Duration
                  :show_seconds,
                  # Time Duration
                  :time_duration_format,
                  # Calculated
                  :calculation, :format,
                  # Integer and Numeric and Calculated
                  :units,
                  # Grid
                  :grid_variables, :multiple_rows, :default_row_number,
                  # Autocomplete
                  :autocomplete_values,
                  # Radio and Checkbox
                  :alignment, :domain_id
  json.path project_variable_path(variable.project, variable, format: :json)
  # json.url project_variable_url(variable.project, variable, format: :json)
end
