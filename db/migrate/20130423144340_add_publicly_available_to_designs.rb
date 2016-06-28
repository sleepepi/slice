class AddPubliclyAvailableToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :publicly_available, :boolean, null: false, default: false
  end
end
