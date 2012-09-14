class AddAutocompleteValuesToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :autocomplete_values, :text
  end
end
