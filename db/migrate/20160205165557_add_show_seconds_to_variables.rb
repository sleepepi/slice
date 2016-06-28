class AddShowSecondsToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :show_seconds, :boolean, null: false, default: true
  end
end
