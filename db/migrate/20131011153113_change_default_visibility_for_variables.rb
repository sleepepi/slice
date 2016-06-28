class ChangeDefaultVisibilityForVariables < ActiveRecord::Migration[4.2]
  def up
    change_column :variables, :display_name_visibility, :string, null: false, default: 'invisible'
  end

  def down
    change_column :variables, :display_name_visibility, :string, null: false, default: 'visible'
  end
end
