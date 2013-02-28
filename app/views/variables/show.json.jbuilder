json.extract! @variable, :description, :header, :name, :display_name, :variable_type, :project_id, :updater_id, :display_name_visibility, :prepend, :append, :created_at, :updated_at,
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
                  :grid_variables, :multiple_rows, :default_row_number,
                  # Autocomplete
                  :autocomplete_values,
                  # Radio and Checkbox
                  :alignment,
                  # Scale
                  :scale_type, :domain_id
