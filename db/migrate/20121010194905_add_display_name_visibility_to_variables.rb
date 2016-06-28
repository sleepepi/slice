class AddDisplayNameVisibilityToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :display_name_visibility, :string, null: false, default: 'visible'
  end
end
