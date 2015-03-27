class AddBetaEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :beta_enabled, :boolean, null: false, default: false
  end
end
