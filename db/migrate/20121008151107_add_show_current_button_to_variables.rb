class AddShowCurrentButtonToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :show_current_button, :boolean, null: false, default: false
  end
end
