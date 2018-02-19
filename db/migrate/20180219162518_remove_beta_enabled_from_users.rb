class RemoveBetaEnabledFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :beta_enabled, :boolean, null: false, default: false
  end
end
