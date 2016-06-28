class AddBetaEnabledToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :beta_enabled, :boolean, null: false, default: false
  end
end
