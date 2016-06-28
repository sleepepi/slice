class AddLockedToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :locked, :boolean, null: false, default: false
  end
end
