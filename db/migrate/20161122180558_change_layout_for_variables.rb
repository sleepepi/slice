class ChangeLayoutForVariables < ActiveRecord::Migration[5.0]
  def up
    change_column :variables, :display_name_visibility, :string, null: false, default: 'visible'
  end

  def down
    change_column :variables, :display_name_visibility, :string, null: false, default: 'invisible'
  end
end
