class AddShowCurrentButtonToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :show_current_button, :boolean, null: false, default: false
  end
end
