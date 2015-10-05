class AddBlindingEnabled < ActiveRecord::Migration
  def change
    add_column :projects, :blinding_enabled, :boolean, null: false, default: false
  end
end
