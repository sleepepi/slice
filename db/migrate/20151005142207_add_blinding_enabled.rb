class AddBlindingEnabled < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :blinding_enabled, :boolean, null: false, default: false
  end
end
