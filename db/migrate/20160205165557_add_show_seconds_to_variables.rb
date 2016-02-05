class AddShowSecondsToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :show_seconds, :boolean, null: false, default: true
  end
end
