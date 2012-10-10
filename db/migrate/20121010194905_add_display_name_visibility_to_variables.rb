class AddDisplayNameVisibilityToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :display_name_visibility, :string, null: false, default: 'visible'
  end
end
