class AddAutocompleteValuesToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :autocomplete_values, :text
  end
end
