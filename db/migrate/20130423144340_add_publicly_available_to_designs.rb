class AddPubliclyAvailableToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :publicly_available, :boolean, null: false, default: false
  end
end
